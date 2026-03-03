import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../data/athkar_data.dart';
import '../model/athkar_model.dart';

class AthkarListController extends GetxController {
  final AthkarData athkarData = AthkarData(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxList<AthkarModel> athkarList = <AthkarModel>[].obs;

  String? _category;
  String get pageTitle => (Get.arguments as Map?)?["titleKey"]?.toString().tr ?? "athkar".tr;

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    _category = (Get.arguments as Map?)?["category"]?.toString();
    fetchAthkar();
  }

  Future<void> fetchAthkar() async {
    if (_isFetching) return;
    _isFetching = true;
    statusRequest.value = StatusRequest.loading;

    try {
      final res = await athkarData.fetchAthkar(page: 1, category: _category);

      res.fold((l) {
        statusRequest.value = l;
      }, (r) {
        try {
          athkarList.clear();
          final data = r["data"];
          final List list = data is List ? data : [];
          for (final e in list) {
            if (e is Map) {
              try {
                athkarList.add(AthkarModel.fromJson(Map<String, dynamic>.from(e)));
              } catch (_) {}
            }
          }
          // Filter by category (API may return all; we filter client-side)
          if (_category != null && _category!.isNotEmpty && athkarList.isNotEmpty) {
            final filtered = athkarList.where((a) {
              final cat = (a.category ?? "").trim();
              if (_category!.contains("صباح") || _category!.contains("morning")) {
                return cat.contains("صباح");
              }
              if (_category!.contains("مساء") || _category!.contains("evening")) {
                return cat.contains("مساء");
              }
              return true;
            }).toList();
            athkarList.assignAll(filtered);
          }
          statusRequest.value = StatusRequest.success;
        } catch (e, st) {
          print("AthkarListController parse error: $e $st");
          statusRequest.value = StatusRequest.serverFailure;
        }
      });
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    if (_isFetching) return;
    await fetchAthkar();
  }
}
