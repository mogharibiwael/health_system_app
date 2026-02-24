import '../../../core/class/crud.dart';
import '../../../core/constant/api_link.dart';

class ChatData {
  final Crud crud;
  ChatData(this.crud);

  Future<dynamic> getHistory({
    required int doctorId,
    required int page,
    String? token,
  }) {
    return crud.getData("${ApiLinks.chatHistory}/$doctorId?page=$page", token: token);
  }

  Future<dynamic> sendMessage({
    required int conversationId,
    required int receiverId,
    required String message,
    String? token,
  }) {
    return crud.postData(
      ApiLinks.chatMessages,
      {
        "conversation_id": conversationId,
        "receiver_id": receiverId,
        "message": message,
      },
      token: token,
    );
  }

  // ✅ NEW
  Future<dynamic> markAsRead({
    required int messageId,
    String? token,
  }) {
    return crud.postData(
      "${ApiLinks.chatMessages}/$messageId/read",
      {}, // غالبًا POST بدون body
      token: token,
    );
  }
}
