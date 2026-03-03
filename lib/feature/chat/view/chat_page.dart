import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/chat_controller.dart';
import '../model/chat_message_model.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (c) => SafeArea(
        child: Scaffold(
        appBar: CustomAppBar(
          title: c.doctorName.isNotEmpty ? c.doctorName : "Chat",
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: c.refreshHistory,
              icon: const Icon(Icons.refresh, color: Color(0xff4a3f6a)),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _HistoryBody(c: c),
                ),
                _Composer(
                  controller: c.messageController,
                  isSending: c.isSending,
                  onSend: c.send,
                ),
              ],
            ),
            if (c.statusRequest == StatusRequest.loading)
              const _LoadingOverlay(),
          ],
        ),
      ),
    ));
  }
}

class _HistoryBody extends StatelessWidget {
  final ChatController c;
  const _HistoryBody({required this.c});

  @override
  Widget build(BuildContext context) {
    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(title: "No internet", onRetry: c.refreshHistory);
    }
    if (c.statusRequest == StatusRequest.serverFailure || c.statusRequest == StatusRequest.failure) {
      return _StateView(title: "Server error", onRetry: c.refreshHistory);
    }

    return RefreshIndicator(
      onRefresh: c.refreshHistory,
      child: c.messages.isEmpty
          ? ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text("No messages yet")),
        ],
      )
          : ListView.builder(
        controller: c.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        itemCount: c.messages.length,
        itemBuilder: (_, i) => _Bubble(message: c.messages[i]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessageModel message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isMe ? AppColor.primary.withOpacity(0.12) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMe ? AppColor.primary.withOpacity(0.25) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time(message.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                if (isMe) ...[
                  const SizedBox(width: 8),
                  Icon(
                    _statusIcon(message),
                    size: 16,
                    color: message.pending ? Colors.grey.shade700 : AppColor.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(ChatMessageModel m) {
    if (m.pending) return Icons.schedule;      // ⏳
    if (m.read == true) return Icons.done_all; // ✅✅
    return Icons.check;                        // ✅
  }

  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
}


class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => isSending ? null : onSend(),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              width: 46,
              child: ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.15),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final String title;
  final VoidCallback onRetry;
  const _StateView({required this.title, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text("Retry"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
