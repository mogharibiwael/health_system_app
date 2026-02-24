import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/routes/app_route.dart';

import '../../../../core/class/status_request.dart';
import '../../../../core/constant/theme/colors.dart';
import '../../../../core/shared/widgets/drawer.dart';
import '../controller/doctor_patients_controller.dart';
import '../model/patient_model.dart';

class DoctorPatientsPage extends GetView<DoctorPatientsController> {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorPatientsController>(
      builder: (c) => Scaffold(
        drawer: HomeDrawer(controller: controller),

        appBar: AppBar(
          title: const Text("Patients"),
          actions: [
            IconButton(
              onPressed: c.refreshPatients,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(DoctorPatientsController c) {
    if (c.statusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.statusRequest == StatusRequest.offlineFailure) {
      return _StateView(
        title: "No internet connection",
        buttonText: "Retry",
        onRetry: () => c.fetchPatients(first: true),
      );
    }

    if (c.statusRequest == StatusRequest.serverFailure ||
        c.statusRequest == StatusRequest.failure) {
      return _StateView(
        title: "Server error",
        buttonText: "Retry",
        onRetry: () => c.fetchPatients(first: true),
      );
    }

    if (c.patients.isEmpty) {
      return _StateView(
        title: "No patients found",
        buttonText: "Refresh",
        onRetry: c.refreshPatients,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
          c.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: c.refreshPatients,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: c.patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _PatientCard(
            patient: c.patients[i],
            onTap: () {
              Get.toNamed(
                AppRoute.patientDetails, // غيّرها لو اسم الراوت مختلف
                arguments: c.patients[i], // نرسل الموديل كامل
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = patient.fullname;
    final email = patient.user?.email ?? "-";
    final phone = patient.phoneNumber ?? "-";

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
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColor.primary.withOpacity(0.12),
              child: Icon(Icons.person_outline, color: AppColor.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Pill(text: "Phone: $phone"),
                      const SizedBox(width: 8),
                      _Pill(text: "Gender: ${patient.gender ?? '-'}"),
                    ],
                  )
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

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
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
