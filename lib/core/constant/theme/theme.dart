import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData themeData = ThemeData(
  fontFamily: "Cairo",
  textTheme: TextTheme(
    bodySmall: TextStyle(fontSize: 20, color: AppColor.textColor),
    titleMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColor.white,
    ),
  ),
);
