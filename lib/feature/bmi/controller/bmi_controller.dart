// bmi_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BmiController extends GetxController {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String gender = "male";
  String activityLevel = "sedentary";

  double? bmi;
  double? bmr;
  double? physicalActivityEnergy; // الناتج بعد ضرب BMR في معامل النشاط
  double? tef;                   // التأثير الحراري للطعام (10%)
  double? totalKcal;             // المجموع النهائي (النشاط الداخلي)

  String bmiStatus = "";

  // معاملات النشاط الفيزيائي (Physical Activity) كما وردت في الصورة
  double _getActivityFactor(String level) {
    switch (level) {
      case "sedentary": return 1.2;     // خامل
      case "low": return 1.3;           // نشاط منخفض
      case "active": return 1.5;        // نشاط متوسط
      case "very": return 1.7;          // نشاط عالي جداً
      case "extra": return 1.9;         // نشاط عالي جداً جداً (1.9 - 2)
      default: return 1.2;
    }
  }

  void calculate() {
    final hStr = heightController.text.trim();
    final wStr = weightController.text.trim();
    final aStr = ageController.text.trim();

    if (hStr.isEmpty || wStr.isEmpty || aStr.isEmpty) return;

    final double weight = double.parse(wStr);
    final double heightCm = double.parse(hStr);
    final int age = int.parse(aStr);

    // 1. حساب BMI (كما في الصورة: الوزن بالكيلو / مربع الطول بالمتر)
    final double heightM = heightCm / 100;
    bmi = weight / (heightM * heightM);
    bmiStatus = _getBmiStatus(bmi!);

    // 2. حساب BMR (معادلة Mifflin-St Jeor الموضحة بالصورة)
    // (10 * weight) + (6.25 * heightCm) - (5 * age)
    double baseBmr = (10 * weight) + (6.25 * heightCm) - (5 * age);
    bmr = (gender == "male") ? (baseBmr + 5) : (baseBmr - 161);

    // 3. حساب الطاقة مع النشاط الفيزيائي (Physical Activity)
    // كما في المثال بالصورة: 1500 (BMR) * 1.3 (Low Active) = 1950
    final factor = _getActivityFactor(activityLevel);
    physicalActivityEnergy = bmr! * factor;

    // 4. حساب TEF (التأثير الحراري للطعام)
    // كما في الصورة: 1950 * 10% = 195
    tef = physicalActivityEnergy! * 0.10;

    // 5. المجموع النهائي (النشاط الداخلي)
    // كما في الصورة: 1950 + 195 = 2145
    totalKcal = physicalActivityEnergy! + tef!;

    update();
  }

  String _getBmiStatus(double v) {
    // تصنيفات الـ BMI المكتوبة في الجدول بالصورة
    if (v < 18.5) return "Underweight (نقص وزن)";
    if (v >= 18.5 && v <= 24.9) return "Normal (وزن مثالي)";
    if (v >= 25 && v <= 29.9) return "Overweight (زيادة وزن)";
    if (v >= 30 && v <= 34.9) return "Obesity I (سمنة درجة 1)";
    if (v >= 35 && v <= 39.9) return "Obesity II (سمنة درجة 2)";
    return "Obesity III (سمنة مفرطة)";
  }
}