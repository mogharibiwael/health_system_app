import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/feature/home/controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text("homeTitle".tr),
        ),
        drawer: _HomeDrawer(controller: c),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _HomeActionCard(
                icon: Icons.medical_services_outlined,
                title: "doctorsList".tr,
                subtitle: "doctorsListDesc".tr,
                onTap: c.goDoctors,
              ),
              const SizedBox(height: 12),
              _HomeActionCard(
                icon: Icons.lightbulb_outline,
                title: "tips".tr,
                subtitle: "tipsDesc".tr,
                onTap: c.goTips,
              ),
              const SizedBox(height: 12),
              _HomeActionCard(
                icon: Icons.monitor_heart_outlined,
                title: "bmiCalc".tr,
                subtitle: "bmiCalcDesc".tr,
                onTap: c.goBmi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  final HomeController controller;
  const _HomeDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColor.primary.withOpacity(0.2),
                    child: const Icon(Icons.person_outline),
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
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

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

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: Text("logout".tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColor.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
