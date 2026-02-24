import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _goNext();
  }

  void _goNext() {
    // عرض السبلّاش قليلاً ثم الانتقال إلى gate
    Future.delayed(const Duration(milliseconds: 600), () {
      Get.offAllNamed(AppRoute.gate);
    });
  }
}
