import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/class/status_request.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';
import 'controller/doctor_details_controller.dart';
import 'data/subscription_data.dart';
import 'model/doctor_model.dart';


class PaymentInvoiceController extends GetxController {
  final MyServices myServices = Get.find();
  final SubscriptionData subscriptionData = SubscriptionData(Get.find());
  final ImagePicker _picker = ImagePicker();

  late DoctorModel doctor;
  late Map<String, dynamic> subscriptionForm;

  File? receiptImage;
  StatusRequest statusRequest = StatusRequest.success;
  int? _userId;

  bool get isLoading => statusRequest == StatusRequest.loading;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments as Map<String, dynamic>?;
    if (arg == null) return;
    doctor = DoctorModel.fromJson(arg['doctor'] as Map<String, dynamic>);
    subscriptionForm = Map<String, dynamic>.from(arg);
    _userId = myServices.userId;
  }

  String get doctorDisplayName {
    final n = doctor.name;
    if (n.startsWith("د.") || n.startsWith("Dr.")) return n;
    return Get.locale?.languageCode == 'ar' ? "د. $n" : "Dr. $n";
  }

  String get bankAccount => doctor.bankAccount ?? "-";
  String get dietPrice => doctor.consultationFee ?? "-";

  Future<void> pickReceipt() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      receiptImage = File(file.path);
      update();
    }
  }

  Future<void> submitSubscription() async {
    if (_userId == null) {
      Get.snackbar("Error", "User session not found");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    const durationMonths = 12;
    final startDate = DateTime.now();
    final endDate = DateTime(
      startDate.year,
      startDate.month + durationMonths,
      startDate.day,
    );

    final priceValue = double.tryParse(
      dietPrice.replaceAll(RegExp(r'[^\d.]'), ''),
    ) ?? 0.0;

    final body = {
      "user_id": _userId,
      "doctor_id": doctor.id,
      "plan": "premium",
      "plan_type": "basic",
      "price": priceValue,
      "duration_months": durationMonths,
      "start_date": startDate.toIso8601String().substring(0, 10),
      "end_date": endDate.toIso8601String().substring(0, 10),
      "full_name": subscriptionForm["full_name"],
      "phone": subscriptionForm["phone"],
      "date_of_birth": subscriptionForm["date_of_birth"],
      "height_cm": subscriptionForm["height_cm"],
      "weight_kg": subscriptionForm["weight_kg"],
      "gender": subscriptionForm["gender"],
      "activity": subscriptionForm["activity"],
    };

    final token = myServices.token;
    final res = await subscriptionData.createSubscription(body, token: token);

    if (res is! Either<StatusRequest, Map<String, dynamic>>) {
      statusRequest = StatusRequest.serverFailure;
      update();
      Get.snackbar("Error", "subscribeFailed".tr);
      return;
    }

    res.fold(
      (l) {
        statusRequest = l;
        update();
        Get.snackbar("Error", "subscribeFailed".tr);
      },
      (r) async {
        statusRequest = StatusRequest.success;
        await myServices.markSubscribedDoctor(doctor.id);
        update();
        // Use closeOverlays: false to avoid "disposed snackbar" crash when popping
        Get.back(closeOverlays: false);
        Get.back(closeOverlays: false);
        try {
          Get.find<DoctorDetailsController>().refreshSubscribed();
        } catch (_) {}
        Get.toNamed(AppRoute.chat, arguments: {
          "doctor_id": doctor.id,
          "receiver_id": doctor.id,
          "doctor_name": doctor.name,
          "conversation_id": doctor.id,
        });
        Get.snackbar("Success", "subscriptionCreated".tr);
      },
    );
  }
}
