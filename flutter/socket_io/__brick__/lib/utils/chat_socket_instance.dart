import 'dart:io';

class ChatEventsConstants {
  static String joinGroup = 'joinGroup';
  static String chatHistory = 'chatHistory';
  static String chatMessage = 'chatMessage';
  static String isRead = 'isRead';
  static String listenRead = 'listenRead';
}

class ChatInstanceConstants {
  static String chatToken = 'chatToken';
  static String messageId = 'messageId';
  static String body = 'body';
  static String image = 'image';
}

class ChatSocketInstance {
  static final Map<String, ChatSocketInstance> _instances = {};
  final String chatToken;
  final Socket socket;

  List _addedListeners = [];

  factory ChatSocketInstance(String chatToken, Socket socket) {
    if (_instances.containsKey(chatToken)) {
      return _instances[chatToken]!;
    } else {
      final newInstance = ChatSocketInstance._internal(chatToken, socket);
      _instances[chatToken] = newInstance;
      return newInstance;
    }
  }

// private constructor
  ChatSocketInstance._internal(this.chatToken, this.socket);

  void joinRoom() {
    socket.emit(ChatEventsConstants.joinGroup,
        {ChatInstanceConstants.chatToken: chatToken});
  }

  void getChatHistory(void Function(List<SocketMessageModel>) callback) {
    if (_addedListeners.contains(ChatEventsConstants.chatHistory)) return;
    socket.on(ChatEventsConstants.chatHistory, (data) {
      _addedListeners.add(ChatEventsConstants.chatHistory);
      final List<SocketMessageModel> _messages = List.from(
        data.map((x) {
          return SocketMessageModel.fromJson(json: x, msgKey: 'id');
        }),
      );
      callback(_messages);
    });
  }

  Future<void> markAsAllRead(
      List<SocketMessageModel> msgList, int userId) async {
    int count = 0;
    for (int i = msgList.length - 1; i >= 0; i--) {
      final SocketMessageModel msgModel = msgList[i];
      if (count == 20 || msgModel.readUserIds.contains(userId)) break;
      final int? messageId = msgModel.messageId;
      if (messageId != null && msgModel.userId != userId.toString()) {
        markAsRead(messageId: messageId);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      count++;
    }
  }

  void listenToNewMessages(void Function(SocketMessageModel) callback) {
    if (_addedListeners.contains(ChatEventsConstants.chatMessage)) return;
    socket.on(ChatEventsConstants.chatMessage, (data) {
      _addedListeners.add(ChatEventsConstants.chatMessage);
      final SocketMessageModel _message =
          SocketMessageModel.fromJson(json: data);
      callback(_message);
    });
  }

  void sendMessage(
      {String? msg,
      List<String>? filePathList,
      Map? otherData,
      Function? callback}) {
    final List<List<int>> imageBytesDataList = [];
    try {
      if (filePathList != null) {
        for (int i = 0; i < filePathList.length; i++) {
          final List<int> imageBytes =
              File(filePathList[i].trim()).readAsBytesSync();
          imageBytesDataList.add(imageBytes);
        }
      }
    } catch (e) {
      CustomException(e.toString(), message: 'Failed to send chat message');
    }
    // if connected only send msg we are  handling auto reconnection
    // disable auto buffering
    if (socket.connected) {
      socket.emitWithAck(
        ChatEventsConstants.chatMessage,
        {
          ChatInstanceConstants.chatToken: chatToken,
          ChatInstanceConstants.body: msg,
          ChatInstanceConstants.image: imageBytesDataList,
          ...?otherData
        },
        ack: (data) {
          if (callback != null) callback(data);
        },
      );
    }
  }

  void markAsRead({required int messageId}) {
    socket.emit(ChatEventsConstants.isRead, {
      ChatInstanceConstants.chatToken: chatToken,
      ChatInstanceConstants.messageId: messageId,
    });
  }

  void listenToIsRead(void Function(Map) callback) {
    if (_addedListeners.contains(ChatEventsConstants.listenRead)) return;
    socket.on(ChatEventsConstants.listenRead, (data) {
      _addedListeners.add(ChatEventsConstants.listenRead);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (data["read_user_ids"] != null && data["message_id"] != null) {
          callback(data);
        }
      });
    });
  }

  void removeAllListeners() {
    for (final listener in _addedListeners) {
      socket.off(listener);
    }
    _addedListeners = [];
  }

  // dispose
  void dispose() {
    removeAllListeners();
    _instances.remove(chatToken);
  }
}
