import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor_model.dart';

class DoctorsPage extends GetView<DoctorsController> {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorsController>(
      builder: (c) => Scaffold(
        appBar: CustomAppBar(
          title: "doctorsList".tr,
          showBackButton: true,
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

  static const Color _textPurple = Color(0xff67025F);

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isAr) ...[
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    size: 32,
                    color: _textPurple,
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  doctor.name,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isAr) ...[
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    size: 32,
                    color: _textPurple,
                  ),
                ),
              ],
            ],
          ),
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
