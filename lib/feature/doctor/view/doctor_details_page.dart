import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/doctor_details_controller.dart';

class DoctorDetailsPage extends GetView<DoctorDetailsController> {
  const DoctorDetailsPage({super.key});

  static const Color _cardGrey = Color(0xffE4E0E4);
  static const Color _textPurple = Color(0xff67025F);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorDetailsController>(
      builder: (c) => SafeArea(
        child: Scaffold(
        appBar: CustomAppBar(
          title: "doctorDetails".tr,
          showBackButton: true,
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                // Circular illustration
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f4f8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 72,
                      color: _textPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Name card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: _cardGrey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    c.doctor.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _textPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Details section
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: "personalEmail".tr,
                  value: c.doctor.email ?? "-",
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: "phone".tr,
                  value: c.doctor.phone ?? "-",
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.account_balance_outlined,
                  label: "bankAccount".tr,
                  value: c.doctor.bankAccount ?? "-",
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: Icons.payments_outlined,
                  label: "dietPrice".tr,
                  value: c.doctor.consultationFee ?? "-",
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: c.statusRequest == StatusRequest.loading
                        ? null
                        : (c.isSubscribed ? c.goToChat : c.openVirtualPaymentSheet),
                    icon: Icon(c.isSubscribed ? Icons.chat_bubble_outline : Icons.lock_outline),
                    label: Text(c.isSubscribed ? "Chat" : "Subscribe"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (c.statusRequest == StatusRequest.loading) const _LoadingOverlay(),
          ],
        ),
      ),
    ));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _textPurple = Color(0xff67025F);

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAr) ...[
          Expanded(
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: " : $label",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, size: 24, color: _textPurple),
        ] else ...[
          Icon(icon, size: 24, color: _textPurple),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: "$label : ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _textPurple,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ],
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
