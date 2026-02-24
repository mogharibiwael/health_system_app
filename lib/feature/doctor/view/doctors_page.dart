import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor_model.dart';

class DoctorsPage extends GetView<DoctorsController> {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorsController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text("doctorsList".tr),
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(DoctorsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchDoctors,
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _StateView(
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.fetchDoctors,
      );
    }

    if (c.doctors.isEmpty) {
      return _StateView(
        title: "noDoctors".tr,
        buttonText: "refresh".tr,
        onRetry: c.refreshDoctors,
      );
    }

    return RefreshIndicator(
      onRefresh: c.refreshDoctors,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: c.doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final d = c.doctors[index];
          return _DoctorCard(
            doctor: d,
            onTap: () {
              // ✅ Open doctor details page
              Get.toNamed("/doctor-details", arguments: d); // DoctorModel
              // إذا تفضّل Map:
              // Get.toNamed("/doctor-details", arguments: d.toJson());
            },
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final availableText = doctor.isAvailable ? "available".tr : "notAvailable".tr;
    final verifiedText = doctor.isVerified ? "verified".tr : "notVerified".tr;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColor.primary.withOpacity(0.12),
              child: Icon(Icons.person_outline, color: AppColor.primary),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        text: verifiedText,
                        filled: doctor.isVerified,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    doctor.specialization ?? "-",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.star_border,
                        text: "${"rating".tr}: ${doctor.rating}",
                      ),
                      _InfoPill(
                        icon: Icons.schedule,
                        text: doctor.yearsOfExperience == null
                            ? "${"experience".tr}: -"
                            : "${"experience".tr}: ${doctor.yearsOfExperience} ${"years".tr}",
                      ),
                      _InfoPill(
                        icon: Icons.payments_outlined,
                        text: doctor.consultationFee == null
                            ? "${"fee".tr}: -"
                            : "${"fee".tr}: ${doctor.consultationFee}",
                      ),
                      _InfoPill(
                        icon: Icons.circle,
                        text: availableText,
                        dotColor: doctor.isAvailable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),

                  if ((doctor.bio ?? "").trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      doctor.bio!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? dotColor;

  const _InfoPill({
    required this.icon,
    required this.text,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 16),
            const SizedBox(width: 6),
          ],
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool filled;

  const _Chip({
    required this.text,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? AppColor.primary.withOpacity(0.12) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? AppColor.primary.withOpacity(0.35) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: filled ? AppColor.primary : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
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
