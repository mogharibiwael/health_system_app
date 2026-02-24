import 'package:nutri_guide/core/constant/api_link.dart';

import '../../../core/class/crud.dart';

class SubscriptionData {
  final Crud crud;
  SubscriptionData(this.crud);

  Future<dynamic> createSubscription(Map<String, dynamic> body, {String? token}) async {
    return await crud.postData(ApiLinks.subscriptions, body, token: token);
  }
}
