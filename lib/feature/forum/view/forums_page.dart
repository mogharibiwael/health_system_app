import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/forums_controller.dart';
import '../model/forum_model.dart';

class ForumsPage extends GetView<ForumsController> {
  const ForumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForumsController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text("forums".tr),
          centerTitle: true,
          elevation: 0,
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(ForumsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchFirstPage,
      );
    }

    if (c.forums.isEmpty) {
      return _EmptyState(
        icon: Icons.forum_outlined,
        title: "noForums".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshForums,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshForums,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            c.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: c.forums.length + (c.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= c.forums.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final forum = c.forums[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ForumCard(
                forum: forum,
                onTap: () => c.openForum(forum),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ForumCard extends StatelessWidget {
  final ForumModel forum;
  final VoidCallback onTap;

  const _ForumCard({required this.forum, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primary.withOpacity(0.15),
                      AppColor.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.forum_rounded, color: AppColor.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forum.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (forum.description != null &&
                        forum.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        forum.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
