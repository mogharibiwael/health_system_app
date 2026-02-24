import 'package:flutter/material.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:get/get.dart';

import '../../../core/service/serviecs.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routes/app_route.dart';

class HomeDrawer extends StatelessWidget {
  final dynamic controller;
  const HomeDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final MyServices myServices = Get.find();
    final permissions = Permissions(myServices);
    final bool isSubscribed = myServices.subscribedDoctorIds.isNotEmpty;
    final bool showForums = permissions.isDoctor || permissions.isAdmin || (permissions.isPatient && isSubscribed);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ─── User Header ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary.withOpacity(0.12),
                    AppColor.primary.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColor.primary.withOpacity(0.2),
                    child: Text(
                      _initials(controller.userName),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.userEmail,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ─── Info tiles ───
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text("phone".tr),
              subtitle: Text(controller.userPhone),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text("role".tr),
              subtitle: Text(controller.userRole),
            ),

            const Divider(height: 1),

            // ─── Forums (conditional) ───
            if (showForums)
              ListTile(
                leading: Icon(Icons.forum_outlined, color: AppColor.primary),
                title: Text(
                  "forums".tr,
                  style: TextStyle(fontWeight: FontWeight.w500, color: AppColor.primary),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  Get.toNamed(AppRoute.forums);
                },
              ),

            const Spacer(),

            // ─── Logout ───
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: Text("logout".tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }
}
