class SocketMessageModel {
  final String userId; // sender_id
  final String body;

  // final String participantType;
  final DateTime createdAt;
  final List<String>? attachmentUrls;
  bool isNotSend;
  final String? temporaryMsgId;
  final Map? otherData;
  final int? messageId;
  List readUserIds;

  SocketMessageModel({
    required this.userId,
    required this.body,
    // required this.participantType,
    required this.createdAt,
    this.attachmentUrls,
    this.isNotSend = false,
    this.temporaryMsgId,
    this.otherData,
    this.messageId,
    this.readUserIds = const [],
  });

  factory SocketMessageModel.fromJson({var json, String msgKey = 'message_id'}) {
    return SocketMessageModel(
      body: json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      userId: json['sender_id'].toString(),
      messageId: json[msgKey] is String ? int.tryParse(json[msgKey]) : json[msgKey],
      temporaryMsgId: json['temporary_msg_id'],
      readUserIds: json['read_user_ids'] ?? [],
      // participantType: json['participant_type'],
      // attachmentUrls: List<String>.from(
      //   json['message_attachment'].map((x) => x['document_url']['url']),
      // ),
    );
  }
}
