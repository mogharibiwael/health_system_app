import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/asset.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/permissions/permissions.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

/// Drawer matching the design: logo header, menu items, close button.
class HomeDrawer extends StatelessWidget {
  final dynamic controller;
  const HomeDrawer({super.key, required this.controller});

  static const Color _drawerBg = Color(0xff9F8A9A);
  static const Color _drawerBgLight = Color(0xffb5a3b0);

  @override
  Widget build(BuildContext context) {
    final myServices = Get.find<MyServices>();
    final permissions = Permissions(myServices);
    final isDoctor = permissions.isDoctor || permissions.isAdmin;
    final isPatientSubscribed = !isDoctor && myServices.subscribedDoctorIds.isNotEmpty;
    final userName = myServices.user?["name"]?.toString().trim();
    final displayName = (userName != null && userName.isNotEmpty) ? userName : "User";

    return Drawer(
      child: Container(
        color: _drawerBg,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // ─── Logo (tappable → profile/doctor info) ───
              Center(
                child: GestureDetector(
                  onTap: () => _navigate(context, "/edit-profile"),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(ImageAssets.logo, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ─── User/Doctor name under logo ───
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // ─── Menu items ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (isDoctor)
                      _DrawerItem(
                        icon: Icons.people_outline,
                        label: "patientsList".tr,
                        onTap: () => _navigate(context, AppRoute.doctorHome),
                      ),
                    if (!isDoctor)
                      _DrawerItem(
                        icon: Icons.edit_note,
                        label: "editPersonalInfo".tr,
                        onTap: () => _navigate(context, AppRoute.patientProfile),
                      ),
                    if (isPatientSubscribed) ...[
                      _DrawerItem(
                        icon: Icons.restaurant_menu_outlined,
                        label: "myDiet".tr,
                        onTap: () => _navigate(context, AppRoute.diet),
                      ),
                      _DrawerItem(
                        icon: Icons.forum_outlined,
                        label: "forums".tr,
                        onTap: () => _navigate(context, AppRoute.forums),
                      ),
                    ],
                    if (isDoctor)
                      _DrawerItem(
                        icon: Icons.assessment_outlined,
                        label: "reports".tr,
                        onTap: () => _navigate(context, AppRoute.doctorDiets),
                      ),
                    // _DrawerItem(
                    //   icon: Icons.calculate_outlined,
                    //   label: "bodyCalculations".tr,
                    //   onTap: () => _navigate(context, "/bmi"),
                    // ),
                    _DrawerItem(
                      icon: Icons.medical_services_outlined,
                      label: "medicalExaminations".tr,
                      onTap: () => _navigate(context, AppRoute.medicalTests),
                    ),
                    _DrawerItem(
                      icon: Icons.help_outline,
                      label: "helpFiles".tr,
                      onTap: () => _navigate(context, AppRoute.medicalFiles),
                    ),
                    _DrawerItem(
                      icon: Icons.language,
                      label: "language".tr,
                      onTap: () => _navigate(context, "/settings"),
                    ),
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      label: "mainMenu".tr,
                      onTap: () => _navigateToHome(context, isDoctor),
                    ),

                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white24),
              // ─── Logout button ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "logout".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    Get.toNamed(route);
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();
    final myServices = Get.find<MyServices>();
    await myServices.clearSession();
    Get.offAllNamed(AppRoute.login);
  }

  void _navigateToHome(BuildContext context, bool isDoctor) {
    Navigator.of(context).pop();
    if (isDoctor) {
      Get.offAllNamed(AppRoute.doctorWelcome);
    } else {
      Get.offAllNamed(AppRoute.home);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: isAr ? TextAlign.right : TextAlign.left,
      ),
      trailing: null,
      onTap: onTap,
    );
  }
}
