void initSocket() {
  socket = SocketUtils(Config.appFlavor!.consultationServiceBaseUrl).instance;

  socket.connect();
  socket.onConnect((_) {
    // //  way to fight buffering on client side , not send message automatically if the newtwork disconnects and reconnects
    socket.sendBuffer = [];
    isSocketConnected = true;
    isHandleReconnectCalled = false;
    chatSocketInstance = ChatSocketInstance(chatToken, socket);
    debugPrint('socket connection established');
    onConnectedToSocket();
  });
  debugPrint("is connected: ${socket.connected}");
  socket.onDisconnect((_) {
    debugPrint('Connection Disconnection');
  });
  socket.onError((err) => debugPrint(err));
  socket.onReconnect((_) {
    isSocketConnected = true;
    debugPrint('Reconnected');
  });
  socket.onReconnectAttempt((_) {
    debugPrint('reconnect attempt');
    if (isHandleReconnectCalled == false) {
      debugPrint('reconnecting...');
      isSocketConnected = false;
      handleReconnect();
      isHandleReconnectCalled = true;
    }
  });

  socket.onReconnectError((err) {
    debugPrint('reconnect error: $err');
  });
  socket.onConnectError((err) {
    debugPrint('connect error: $err');
  });
  socket.onReconnectFailed((_) {
    debugPrint('reconnect failed');
  });
  socket.onConnectTimeout((_) {
    debugPrint('connect timeout');
  });
  socket.onPing((_) {
    debugPrint('ping');
  });
  socket.onReconnect((_) {
    debugPrint('reconnected');
  });
}

Future onConnectedToSocket() async {
  // if reconnected then add all the messages in the stack to the ui and send again to the server

  // final int msgStackLength = messageStack.length;
  // If reconnect before getting history called emit all the messages in the stack

  chatSocketInstance!.getChatHistory((List<SocketMessageModel> messages) {
    chatSocketInstance!.markAsAllRead(messages, int.parse(userId));
  });

  chatSocketInstance!.listenToNewMessages((SocketMessageModel message) {
    if (message.messageId != null) {
      chatSocketInstance!.markAsRead(messageId: message.messageId!);
    }
  });
  chatSocketInstance!.joinRoom();
  chatSocketInstance!.listenToIsRead((Map data) {
    // update only the
  });

  // joinRoom();
}
