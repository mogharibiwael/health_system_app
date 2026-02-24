class ChatMessageModel {
  final int id;
  final int userId;
  final int doctorId;
  final String message;
  final DateTime createdAt;
  final bool isMe;
  final bool pending;
  final bool read;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.message,
    required this.createdAt,
    required this.isMe,
    this.pending = false,
    this.read = false,
  });

  ChatMessageModel copyWith({
    bool? pending,
    bool? read,
  }) {
    return ChatMessageModel(
      id: id,
      userId: userId,
      doctorId: doctorId,
      message: message,
      createdAt: createdAt,
      isMe: isMe,
      pending: pending ?? this.pending,
      read: read ?? this.read,
    );
  }

  factory ChatMessageModel.fromHistoryJson(Map<String, dynamic> json, {required int myUserId}) {
    final uid = (json["user_id"] is int) ? json["user_id"] : int.tryParse("${json["user_id"]}") ?? 0;
    final readRaw = (json["read"] ?? "false").toString().toLowerCase();
    final isRead = readRaw == "true" || readRaw == "1";

    return ChatMessageModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      userId: uid,
      doctorId: (json["doctor_id"] is int) ? json["doctor_id"] : int.tryParse("${json["doctor_id"]}") ?? 0,
      message: (json["message"] ?? "").toString(),
      createdAt: DateTime.tryParse((json["created_at"] ?? "").toString()) ?? DateTime.now(),
      isMe: uid == myUserId,
      read: isRead,
    );
  }
}
