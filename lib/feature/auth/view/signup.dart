import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';
import 'package:nutri_guide/feature/auth/widget/logo_auth.dart';

import '../../../core/shared/widgets/global_button.dart';
import '../../../core/shared/widgets/text_form_field.dart';

class Signup extends GetView<SignupController> {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    print("object");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LogoAuth(),
            CustomTextFormField(
              controller: controller.usernameController,
              keyboardType: TextInputType.text,
              label: 'username'.tr,
              hintText: 'enterUserName'.tr,
              icon: Icons.person_outline,
              obscureText: false,
            ),
            CustomTextFormField(
              controller: controller.emailController,
              label: 'password'.tr,
              keyboardType: TextInputType.emailAddress,
              hintText: 'hintPassword'.tr,
              icon: Icons.email,
              obscureText: false,
            ),
            CustomTextFormField(
              controller: controller.passwordController,
              label: 'password'.tr,
              keyboardType: TextInputType.text,
              hintText: 'hintPassword'.tr,
              icon: Icons.lock_outline,
              obscureText: true,

            ),
            CustomTextFormField(
              controller: controller.passwordController,
              label: 'password'.tr,
              keyboardType: TextInputType.text,
              hintText: 'hintPassword'.tr,
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            GlobalButton(textButton: 'signup'.tr, onPress: () {}),
          ],
        ),
      ),
    );
  }
}
