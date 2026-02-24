import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/tips_controller.dart';

class TipsPage extends GetView<TipsController> {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TipsController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text("tips".tr), // add localization key if you want
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(TipsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(
        title: "No internet connection",
        buttonText: "Retry",
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _StateView(
        title: "Server error",
        buttonText: "Retry",
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.tips.isEmpty) {
      return _StateView(
        title: "No tips found",
        buttonText: "Refresh",
        onRetry: c.refreshTips,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshTips,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            c.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: c.tips.length + (c.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= c.tips.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final tip = c.tips[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lightbulb_outline, color: AppColor.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip.describtion,
                      style: const TextStyle(fontSize: 15, height: 1.3),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _StateView({
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: Text(buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
