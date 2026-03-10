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

  /// User type: "doctor", "user", "admin". Falls back to user["type"] or "doctor" if user has doctor object.
  String? get type {
    final stored = sharedPreferences.getString("type");
    if (stored != null && stored.trim().isNotEmpty) return stored;
    final u = user;
    if (u == null) return null;
    final t = (u["type"] ?? "").toString().trim().toLowerCase();
    if (t.isNotEmpty) return t;
    if (u["doctor"] != null) return "doctor";
    return "user";
  }

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

  /// Doctor's record id (from doctors table). Required for diet-plans API.
  /// Backend expects doctor_id, not user_id. Read from user["doctor_id"] or user["doctor"]["id"].
  int? get doctorId {
    final u = user;
    if (u == null) return null;
    final did = u["doctor_id"];
    if (did != null) {
      if (did is int) return did;
      final parsed = int.tryParse(did.toString());
      if (parsed != null) return parsed;
    }
    final doctor = u["doctor"];
    if (doctor is Map) {
      final id = doctor["id"];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? "");
    }
    return null;
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

  /// Replace subscribed doctor ids (e.g. after fetching from backend)
  Future<void> setSubscribedDoctorIds(Set<int> ids) async {
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
