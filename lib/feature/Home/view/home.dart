import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/shared/widgets/drawer.dart';
import 'package:nutri_guide/feature/ads/model/ad_model.dart';

import '../../home/controller/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text("homeTitle".tr),
        ),
        drawer: HomeDrawer(controller: controller),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            // ─── Top: Ads carousel (public/ads) ───
            _AdsCarousel(controller: controller),
            const SizedBox(height: 20),

            // ─── Always for user: Doctors, BMI/BMR, Tips ───
            _HomeActionCard(
              icon: Icons.medical_services_outlined,
              title: "doctorsList".tr,
              subtitle: "doctorsListDesc".tr,
              onTap: controller.goDoctors,
            ),
            const SizedBox(height: 12),
            _HomeActionCard(
              icon: Icons.lightbulb_outline,
              title: "tips".tr,
              subtitle: "tipsDesc".tr,
              onTap: controller.goTips,
            ),
            const SizedBox(height: 12),
            _HomeActionCard(
              icon: Icons.monitor_heart_outlined,
              title: "bmiCalc".tr,
              subtitle: "bmiCalcDesc".tr,
              onTap: controller.goBmi,
            ),

            // ─── Only when subscribed with a doctor ───
            if (controller.isSubscribed) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "subscribedFeatures".tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              _HomeActionCard(
                icon: Icons.forum_outlined,
                title: "forums".tr,
                subtitle: "forumsDesc".tr,
                onTap: controller.goForums,
              ),
              const SizedBox(height: 12),
              _HomeActionCard(
                icon: Icons.event_note_outlined,
                title: "consultations".tr,
                subtitle: "consultationsDesc".tr,
                onTap: controller.goConsultations,
              ),
              const SizedBox(height: 12),
              _HomeActionCard(
                icon: Icons.restaurant_menu_outlined,
                title: "myDiet".tr,
                subtitle: "myDietDesc".tr,
                onTap: controller.goDiet,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ads carousel at top (public/ads)
class _AdsCarousel extends StatelessWidget {
  final HomeController controller;

  const _AdsCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.adsStatus == StatusRequest.loading && controller.ads.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (controller.ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 168,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: controller.ads.length,
        itemBuilder: (context, index) {
          final ad = controller.ads[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _AdCard(ad: ad),
          );
        },
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final AdModel ad;

  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {
          if (ad.link != null && ad.link!.isNotEmpty) {
            // Optionally launch URL: url_launcher
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColor.primary.withOpacity(0.15),
                AppColor.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColor.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ad.imageUrl != null && ad.imageUrl!.isNotEmpty
                ? Image.network(
                    ad.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _AdPlaceholder(ad: ad),
                  )
                : _AdPlaceholder(ad: ad),
          ),
        ),
      ),
    );
  }
}

class _AdPlaceholder extends StatelessWidget {
  final AdModel ad;

  const _AdPlaceholder({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad.title != null && ad.title!.isNotEmpty)
            Text(
              ad.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (ad.description != null && ad.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ad.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
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
