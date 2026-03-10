import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/asset.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/doctor_details_controller.dart';


class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> with WidgetsBindingObserver {
  static const Color _darkPurple = Color(0xff4a3f6a);
  static const Color _lightBlue = Color(0xffe8f4f8);
  static const Color _lightPurple = Color(0xffe4dce8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<DoctorDetailsController>().refreshSubscribed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return GetBuilder<DoctorDetailsController>(
      builder: (c) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: CustomAppBar(
              title: "doctorDetails".tr,
              showBackButton: true,
              showLogo: true,
            ),
            body: Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 8),
                    // Top section - light grey with semi-circular blend and circle at bottom-left
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: AppColor.customGrey,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const SizedBox(height: 100),

                          Positioned(
                            left: 0,
                            bottom: -90,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: _lightBlue,
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
                              child: Image.asset(
                                "assets/images/doc.png"

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(52, 18, 24, 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              _doctorDisplayName(c.doctor.name),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _darkPurple,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Image.asset(
                              ImageAssets.logo,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _DetailRow(
                                  icon: Icons.email_outlined,
                                  label: "personalEmail".tr,
                                  value: c.doctor.email ?? "-",
                                ),
                                const SizedBox(height: 18),
                                _DetailRow(
                                  icon: Icons.phone_outlined,
                                  label: "phone".tr,
                                  value: c.doctor.phone ?? "-",
                                ),
                                const SizedBox(height: 18),
                                _DetailRow(
                                  icon: Icons.account_balance_outlined,
                                  label: "bankAccount".tr,
                                  value: c.doctor.bankAccount ?? "-",
                                ),
                                const SizedBox(height: 18),
                                _DetailRow(
                                  icon: Icons.payments_outlined,
                                  label: "dietPrice".tr,
                                  value: _formatFee(c.doctor.consultationFee),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Image.asset(
                              ImageAssets.logo,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: c.statusRequest == StatusRequest.loading
                              ? null
                              : (c.isSubscribed ? c.goToChat : c.openVirtualPaymentSheet),
                          icon: Icon(c.isSubscribed ? Icons.chat_bubble_outline : Icons.lock_outline),
                          label: Text(c.isSubscribed ? "chat".tr : "subscribe".tr),
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
                    ),
                  ],
                ),

                if (c.statusRequest == StatusRequest.loading) const _LoadingOverlay(),
              ],
            ),
          ),
        ),
      ));

  }

  String _doctorDisplayName(String name) {
    if (name.startsWith("د.") || name.startsWith("Dr.")) return name;
    return Get.locale?.languageCode == 'ar' ? "د. $name" : "Dr. $name";
  }

  String _formatFee(String? fee) {
    if (fee == null || fee.isEmpty) return "-";
    final trimmed = fee.trim();
    if (trimmed.contains("\$") || trimmed.toUpperCase().contains("USD")) return trimmed;
    return "\$$trimmed";
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

  static const Color _labelPurple = Color(0xff4a3f6a);
  static const Color _iconDark = Color(0xff333333);

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    // RTL: value (gray, left) | label (purple) | icon (far right)
    // LTR: icon (far left) | label (purple) | value (gray, right)
    final labelValue = RichText(
      textAlign: isAr ? TextAlign.right : TextAlign.left,
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
        children: !isAr
            ? [
                TextSpan(text: value),
                TextSpan(
                  text: " : $label",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _labelPurple,
                  ),
                ),
              ]
            : [
                TextSpan(
                  text: "$label : ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _labelPurple,
                  ),
                ),
                TextSpan(text: value),
              ],
      ),
    );
    final iconWidget = Icon(icon, size: 24, color: _iconDark);

    if (!isAr) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: labelValue),
          const SizedBox(width: 14),
          iconWidget,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconWidget,
        const SizedBox(width: 14),
        Expanded(child: labelValue),
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
