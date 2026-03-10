import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';
import '../data/subscription_data.dart';
import '../model/doctor_model.dart';
import '../widget/doctor_virtual_payment_sheet.dart';

class DoctorDetailsController extends GetxController {
  final MyServices myServices = Get.find();
  final SubscriptionData subscriptionData = SubscriptionData(Get.find());
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpController = TextEditingController(); // MM/YY
  final TextEditingController cardCvvController = TextEditingController();

  final TextEditingController walletNameController = TextEditingController(); // e.g. "YemenPay"
  final TextEditingController walletNumberController = TextEditingController(); // wallet account/phone
  final TextEditingController walletRefController = TextEditingController(); // transaction ref

  final TextEditingController transferSenderController = TextEditingController(); // اسم المُرسل
  final TextEditingController transferReceiverController = TextEditingController(); // اسم المُستلم
  final TextEditingController transferRefController = TextEditingController(); // رقم/مرجع الحوالة
  final TextEditingController transferAmountController = TextEditingController(); // المبلغ

  late DoctorModel doctor;

  StatusRequest statusRequest = StatusRequest.success;

  // ✅ subscription state
  bool isSubscribed = false;

  // virtual payment state
  String paymentMethod = "card"; // card | cash | wallet

  // plan state
  String planType = "basic";
  int durationMonths = 12;
  double price = 1200;

  int? _userId;

  bool get isLoading => statusRequest == StatusRequest.loading;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is DoctorModel) {
      doctor = arg;
    } else if (arg is Map<String, dynamic>) {
      doctor = DoctorModel.fromJson(arg);
    } else {
      doctor = DoctorModel(
        id: 0,
        name: "-",
        isVerified: false,
        isAvailable: false,
        rating: "0.00",
      );
    }

    _userId = myServices.userId;
    _loadSubscribedState();
  }


  void _loadSubscribedState() {
    isSubscribed = myServices.isSubscribedToDoctor(doctor.id);
    update();
  }

  void refreshSubscribed() {
    _loadSubscribedState();
  }

  void openVirtualPaymentSheet() {
    if (isSubscribed) {
      goToChat();
      return;
    }
    goToSubscriptionInfo();
  }

  void goToSubscriptionInfo() {
    Get.toNamed(AppRoute.subscriptionInfo, arguments: {
      "doctor": doctor.toJson(),
    });
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    update();
  }

  void setPlanType(String type) {
    planType = type;
    update();
  }

  void setDuration(int months) {
    durationMonths = months;
    update();
  }

  void setPrice(double p) {
    price = p;
    update();
  }

  Future<void> confirmPaymentAndSubscribe() async {
    // ✅ validate payment info based on method
    final ok = _validatePayment();
    if (!ok) return;

    statusRequest = StatusRequest.loading;
    update();

    await Future.delayed(const Duration(seconds: 1)); // fake processing

    if (Get.isBottomSheetOpen == true) Get.back();

    await subscribe();
  }

  bool _validatePayment() {
    String err = "";

    if (paymentMethod == "card") {
      if (cardHolderController.text.trim().isEmpty) err = "Enter card holder name";
      else if (cardNumberController.text.trim().length < 12) err = "Enter valid card number";
      else if (cardExpController.text.trim().isEmpty) err = "Enter expiry (MM/YY)";
      else if (cardCvvController.text.trim().length < 3) err = "Enter CVV";
    } else if (paymentMethod == "wallet") {
      if (walletNameController.text.trim().isEmpty) err = "Enter wallet name";
      else if (walletNumberController.text.trim().isEmpty) err = "Enter wallet number";
      else if (walletRefController.text.trim().isEmpty) err = "Enter transaction reference";
    } else if (paymentMethod == "transfer") {
      if (transferSenderController.text.trim().isEmpty) err = "Enter sender name";
      else if (transferReceiverController.text.trim().isEmpty) err = "Enter receiver name";
      else if (transferRefController.text.trim().isEmpty) err = "Enter transfer reference";
      else if (transferAmountController.text.trim().isEmpty) err = "Enter amount";
    }

    if (err.isNotEmpty) {
      Get.snackbar("Error", err, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }


  Future<void> subscribe() async {
    if (_userId == null) {
      statusRequest = StatusRequest.failure;
      update();
      Get.snackbar("Error", "User session not found (missing user id)");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    final startDate = DateTime.now();
    final endDate =
    DateTime(startDate.year, startDate.month + durationMonths, startDate.day);

    final body = {
      "user_id": _userId,
      "doctor_id": doctor.id,
      "plan": "premium",
      "plan_type": planType,
      "price": price,
      "duration_months": durationMonths,
      "start_date": startDate.toIso8601String().substring(0, 10),
      "end_date": endDate.toIso8601String().substring(0, 10),
    };

    final token = myServices.token;

    final res = await subscriptionData.createSubscription(body, token: token);

    // ✅ res = Either<StatusRequest, Map>
    res.fold(
          (l) {
        statusRequest = l;
        update();
        Get.snackbar("Error", "Request failed: $l");
      },
          (r) async {
        statusRequest = StatusRequest.success;

        // ✅ اعتبره نجاح لو رجع id أو status (حسب response عندك)
        // لو عندك حالات أخرى مثل 422 يمكنك فحص r["errors"] هنا
        await myServices.markSubscribedDoctor(doctor.id);
        isSubscribed = true;

        update();

        Get.snackbar("Success", "Subscription created successfully");
        final ok = await Get.toNamed(AppRoute.patientProfile);


        // اختياري: افتح الشات مباشرة
        goToChat();
      },
    );
  }

  void goToChat() {
    if (!isSubscribed) return;

    Get.toNamed(AppRoute.chat, arguments: {
      "doctor_id": doctor.id,
      "receiver_id": doctor.id, // ✅
      "doctor_name": doctor.name,
      "conversation_id": doctor.id, // ✅ optional fallback
    });



  }



  // --- payment inputs ---


// ✅ methods: card | wallet | transfer

  Map<String, dynamic> get paymentInfo {
    switch (paymentMethod) {
      case "card":
        return {
          "method": "card",
          "holder_name": cardHolderController.text.trim(),
          "card_number": cardNumberController.text.trim(),
          "exp": cardExpController.text.trim(),
          "cvv": cardCvvController.text.trim(),
        };
      case "wallet":
        return {
          "method": "wallet",
          "wallet_name": walletNameController.text.trim(),
          "wallet_number": walletNumberController.text.trim(),
          "wallet_ref": walletRefController.text.trim(),
        };
      case "transfer":
        return {
          "method": "transfer",
          "sender_name": transferSenderController.text.trim(),
          "receiver_name": transferReceiverController.text.trim(),
          "transfer_ref": transferRefController.text.trim(),
          "amount": transferAmountController.text.trim(),
        };
      default:
        return {"method": paymentMethod};
    }
  }
  @override
  void onClose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    cardExpController.dispose();
    cardCvvController.dispose();

    walletNameController.dispose();
    walletNumberController.dispose();
    walletRefController.dispose();

    transferSenderController.dispose();
    transferReceiverController.dispose();
    transferRefController.dispose();
    transferAmountController.dispose();

    super.onClose();
  }

}
