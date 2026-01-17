import 'package:flutter/material.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';

class GlobalButton extends StatelessWidget {
  String textButton;
  void Function() onPress;

  GlobalButton({super.key, required this.textButton, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: double.infinity,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: AppColor.primary,
          textStyle: Theme.of(context).textTheme.titleMedium,
          foregroundColor: AppColor.white,
        ),

        onPressed: onPress,
        child: Text(textButton),
      ),
    );
  }
}
