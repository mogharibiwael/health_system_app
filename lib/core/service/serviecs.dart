import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;

  Future<MyServices> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSession({
    required String token,
    required String type, // user / doctor / admin ...
    Map<String, dynamic>? user,
  }) async {
    await sharedPreferences.setString("token", token);
    await sharedPreferences.setString("type", type);
    if (user != null) {
      await sharedPreferences.setString("user", jsonEncode(user));
    }
  }

  String? get token => sharedPreferences.getString("token");
  String? get type => sharedPreferences.getString("type");

  bool get isLoggedIn => token != null && token!.trim().isNotEmpty;

  Map<String, dynamic>? get user {
    final s = sharedPreferences.getString("user");
    if (s == null || s.trim().isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  int? get userId {
    final u = user;
    if (u == null) return null;
    final id = u["id"];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? "");
  }

  // -------------------------------
  // ✅ Subscriptions cache (doctor ids)
  static const String _subsKey = "subscribed_doctor_ids";

  Set<int> get subscribedDoctorIds {
    final list = sharedPreferences.getStringList(_subsKey) ?? <String>[];
    return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  bool isSubscribedToDoctor(int doctorId) => subscribedDoctorIds.contains(doctorId);

  Future<void> markSubscribedDoctor(int doctorId) async {
    final ids = subscribedDoctorIds;
    ids.add(doctorId);
    await sharedPreferences.setStringList(
      _subsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  Future<void> clearSession() async {
    await sharedPreferences.remove("token");
    await sharedPreferences.remove("type");
    await sharedPreferences.remove("user");
    await sharedPreferences.remove(_subsKey );
  }

  // ─────────────────────────────────────────────────────
  // Role helpers
  // ─────────────────────────────────────────────────────

  /// Check if user is patient (type: "patient" or "payed" or "user")
  bool get isPatient {
    if (!isLoggedIn) return false;
    final type = (this.type ?? "").toLowerCase();
    return type == "patient" || type == "payed" || type == "user";
  }

  /// Check if user is doctor
  bool get isDoctor {
    if (!isLoggedIn) return false;
    return (type ?? "").toLowerCase() == "doctor";
  }

  /// Check if user is admin
  bool get isAdmin {
    if (!isLoggedIn) return false;
    return (type ?? "").toLowerCase() == "admin";
  }
}

Future<void> initialServices() async {
  await Get.putAsync(() => MyServices().init());
}
