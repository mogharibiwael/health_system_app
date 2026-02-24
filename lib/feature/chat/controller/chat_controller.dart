import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../data/chat_data.dart';
import '../model/chat_message_model.dart';

class ChatController extends GetxController {
  final MyServices myServices = Get.find();
  final ChatData chatData = ChatData(Get.find());

  late final int doctorId;     // used for /chat/history/{doctorId}
  late int receiverId;         // REQUIRED by POST /chat/messages
  String doctorName = "";

  int myUserId = 0;

  /// IMPORTANT:
  /// If backend expects conversation_id and you don't have it,
  /// we fallback to doctorId (because history endpoint is keyed by doctorId).
  late int conversationId;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StatusRequest statusRequest = StatusRequest.loading; // history loading
  StatusRequest sendStatus = StatusRequest.success;

  final List<ChatMessageModel> messages = [];
  bool get isSending => sendStatus == StatusRequest.loading;

  int currentPage = 1;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map?) ?? {};

    doctorId = (args["doctor_id"] is int)
        ? args["doctor_id"]
        : int.tryParse("${args["doctor_id"]}") ?? 0;

    doctorName = (args["doctor_name"] ?? "").toString();

    // If you passed receiver_id from previous screen keep it,
    // BUT if it's missing we default receiver_id to doctorId (most common for your backend).
    receiverId = (args["receiver_id"] is int)
        ? args["receiver_id"]
        : int.tryParse("${args["receiver_id"]}") ?? 0;

    conversationId = (args["conversation_id"] is int)
        ? args["conversation_id"]
        : int.tryParse("${args["conversation_id"]}") ?? 0;

    if (conversationId == 0) conversationId = doctorId;

    // ✅ Fallback for receiver_id
    // Your backend error says receiver_id is required, and history returns doctor_id.
    // So for patient->doctor messages, receiver_id is most likely doctorId.
    if (receiverId == 0) receiverId = doctorId;

    _loadMyUserId();
    loadHistory(first: true);
  }

  void _loadMyUserId() {
    final u = myServices.user;
    final id = u?["id"];
    if (id is int) myUserId = id;
    if (id is String) myUserId = int.tryParse(id) ?? 0;
  }

  Future<void> loadHistory({bool first = false}) async {
    if (doctorId == 0) {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    if (first) {
      currentPage = 1;
      hasMore = true;
      messages.clear();
      statusRequest = StatusRequest.loading;
      update();
    }

    final res = await chatData.getHistory(
      doctorId: doctorId,
      page: currentPage,
      token: myServices.token,
    );

    statusRequest = handelData(res);
    update();

    res.fold(
          (l) {
        statusRequest = l;
        update();
      },
          (r) {
        final list = (r["data"] as List?) ?? [];

        final newMsgs = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map((e) => ChatMessageModel.fromHistoryJson(e, myUserId: myUserId))
            .toList();

        // sort ascending by createdAt for UI
        newMsgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        messages
          ..clear()
          ..addAll(newMsgs);

        statusRequest = StatusRequest.success;
        update();
        _scrollToBottom();
      },
    );
  }

  Future<void> refreshHistory() async => loadHistory(first: true);

  Future<void> send() async {
    if (isSending) return;

    final text = messageController.text.trim();
    if (text.isEmpty) return;

    if (receiverId == 0) {
      Get.snackbar("Error", "Missing receiver_id");
      return;
    }

    // optimistic
    final optimistic = ChatMessageModel(
      id: -DateTime.now().millisecondsSinceEpoch,
      userId: myUserId,
      doctorId: doctorId,
      message: text,
      createdAt: DateTime.now(),
      isMe: true,
      pending: true,
    );

    messages.add(optimistic);
    messageController.clear();
    update();
    _scrollToBottom();

    sendStatus = StatusRequest.loading;
    update();

    _scrollToBottom();

// ✅ mark read after UI frame
    Future.microtask(() => _markVisibleUnreadAsRead());

    // ✅ Debug (important)
    print("SEND => conversation_id=$conversationId receiver_id=$receiverId doctor_id=$doctorId myUserId=$myUserId msg=$text");

    final res = await chatData.sendMessage(
      conversationId: conversationId, // ✅ not 0 now
      receiverId: receiverId,         // ✅ fallback to doctorId if missing
      message: text,
      token: myServices.token,
    );

    res.fold(
          (l) {
        sendStatus = StatusRequest.success;
        messages.remove(optimistic);
        update();
        Get.snackbar("Error", _mapStatus(l));
      },
          (r) async {
        sendStatus = StatusRequest.success;
        update();

        // ✅ CRITICAL: always sync after send
        await refreshHistory();
      },
    );
  }

  String _mapStatus(StatusRequest s) {
    if (s == StatusRequest.offlineFailure) return "No internet connection";
    if (s == StatusRequest.serverFailure) return "Server error";
    return "Failed";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }


  Future<void> _markVisibleUnreadAsRead() async {
    // mark all unread messages that are not mine
    final unread = messages.where((m) => !m.isMe && !m.read && m.id > 0).toList();
    if (unread.isEmpty) return;

    for (final m in unread) {
      await markAsRead(m.id);
    }
  }

  Future<void> markAsRead(int messageId) async {
    // local update first
    final idx = messages.indexWhere((e) => e.id == messageId);
    if (idx != -1 && !messages[idx].read) {
      messages[idx] = messages[idx].copyWith(read: true);
      update();
    }

    final res = await chatData.markAsRead(
      messageId: messageId,
      token: myServices.token,
    );

    // لو فشل الطلب، رجّعها false (اختياري)
    res.fold?.call(
          (l) {
        final i = messages.indexWhere((e) => e.id == messageId);
        if (i != -1) {
          messages[i] = messages[i].copyWith(read: false);
          update();
        }
      },
          (r) {},
    );
  }

}
