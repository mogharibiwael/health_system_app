import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAwesomeDialog({
  required DialogType type,
  required String title,
  required String desc,
  VoidCallback? onOk,
  bool dismissOnTouchOutside = true,
}) {
  final context = Get.context;
  if (context == null) return;

  AwesomeDialog(
    context: context,
    dialogType: type,
    animType: AnimType.scale,
    title: title,
    desc: desc,
    dismissOnTouchOutside: dismissOnTouchOutside,
    btnOkOnPress: onOk ?? () {},
  ).show();
}
