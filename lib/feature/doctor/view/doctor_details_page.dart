import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/doctor_details_controller.dart';

class DoctorDetailsPage extends GetView<DoctorDetailsController> {
  const DoctorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorDetailsController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("Doctor Details"),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HeaderCard(
                  name: c.doctor.name,
                  specialization: c.doctor.specialization ?? "-",
                  verified: c.doctor.isVerified,
                  available: c.doctor.isAvailable,
                ),
                const SizedBox(height: 12),

                _InfoRow(title: "Rating", value: c.doctor.rating),
                _InfoRow(
                  title: "Experience",
                  value: c.doctor.yearsOfExperience == null
                      ? "-"
                      : "${c.doctor.yearsOfExperience} years",
                ),
                _InfoRow(
                  title: "Fee",
                  value: c.doctor.consultationFee ?? "-",
                ),

                const SizedBox(height: 12),

                if ((c.doctor.bio ?? "").trim().isNotEmpty)
                  _Section(
                    title: "Bio",
                    child: Text(c.doctor.bio!.trim()),
                  ),

                const SizedBox(height: 18),

                // ✅ button changes based on subscription
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: c.statusRequest == StatusRequest.loading
                        ? null
                        : (c.isSubscribed ? c.goToChat : c.openVirtualPaymentSheet),
                    icon: Icon(c.isSubscribed ? Icons.chat_bubble_outline : Icons.lock_outline),
                    label: Text(c.isSubscribed ? "Chat" : "Subscribe"),
                  ),
                ),
              ],
            ),

            if (c.statusRequest == StatusRequest.loading) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

// باقي widgets كما هي عندك (HeaderCard / Chip / InfoRow / Section / LoadingOverlay)
class _HeaderCard extends StatelessWidget {
  final String name;
  final String specialization;
  final bool verified;
  final bool available;

  const _HeaderCard({
    required this.name,
    required this.specialization,
    required this.verified,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
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
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      text: verified ? "Verified" : "Not verified",
                      filled: verified,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(specialization, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                _Chip(
                  text: available ? "Available" : "Not available",
                  filled: available,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool filled;
  const _Chip({required this.text, required this.filled});

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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey.shade700))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          child,
        ],
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
        color: Colors.black.withOpacity(0.25),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
