import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/routes/app_route.dart';
import '../data/forums_data.dart';
import '../model/forum_model.dart';

class ForumsController extends GetxController {
  final ForumsData forumsData = ForumsData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;
  final List<ForumModel> forums = [];

  int currentPage = 1;
  bool hasNextPage = false;
  bool isLoadingMore = false;

  String? get token => myServices.token;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    currentPage = 1;
    forums.clear();
    statusRequest = StatusRequest.loading;
    update();

    final Either<StatusRequest, Map<String, dynamic>> res =
        await forumsData.fetchForums(page: currentPage, token: token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);

      final List data = (r["data"] ?? []) as List;
      forums.addAll(
        data.map((e) => ForumModel.fromJson(e as Map<String, dynamic>)),
      );

      hasNextPage = r["next_page_url"] != null;
      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> refreshForums() async {
    await fetchFirstPage();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore || statusRequest == StatusRequest.loading) return;

    isLoadingMore = true;
    update();

    final nextPage = currentPage + 1;

    final res = await forumsData.fetchForums(page: nextPage, token: token);

    res.fold((l) {
      isLoadingMore = false;
      update();
    }, (r) {
      final List data = (r["data"] ?? []) as List;
      forums.addAll(
        data.map((e) => ForumModel.fromJson(e as Map<String, dynamic>)),
      );

      currentPage = nextPage;
      hasNextPage = r["next_page_url"] != null;
      isLoadingMore = false;
      update();
    });
  }

  void openForum(ForumModel forum) {
    Get.toNamed(AppRoute.forumPosts, arguments: {
      "forum_id": forum.id,
      "forum_name": forum.name,
    });
  }
}
