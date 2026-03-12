import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/asset.dart';
import '../controller/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  ImageAssets.logo,
                  height: 200,
                  fit: BoxFit.contain,
                ),

                _AppNameText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// App name with first word in #67025F and second part in #5B7430.
class _AppNameText extends StatelessWidget {
  static const Color _firstColor = Color(0xff67025F);
  static const Color _secondColor = Color(0xff5B7430);

  @override
  Widget build(BuildContext context) {
    final full = 'appName'.tr;
    final space = full.indexOf(' ');
    final firstWord = space > 0 ? full.substring(0, space) : full;
    final secondPart = space > 0 ? full.substring(space).trim() : '';

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: firstWord, style: TextStyle(color:_firstColor )),
          if (secondPart.isNotEmpty) TextSpan(text: ' $secondPart',style: TextStyle(color:_secondColor )),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
