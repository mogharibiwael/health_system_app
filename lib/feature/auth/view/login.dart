import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';
import 'package:nutri_guide/feature/auth/widget/logo_auth.dart';
import 'package:nutri_guide/feature/auth/widget/text_signup.dart';

import '../../../core/class/status_request.dart';
import '../../../core/shared/widgets/global_button.dart';
import '../../../core/shared/widgets/text_form_field.dart';

class Login extends GetView<LoginController> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LogoAuth(),
              CustomTextFormField(
                controller: controller.emailController,
                label: 'username'.tr,
                hintText: 'enterUserName'.tr,
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress, obscureText: false,
        
              ),
              CustomTextFormField(
                controller: controller.passwordController,
                label: 'password'.tr,
                hintText: 'hintPassword'.tr,
                icon: Icons.lock_outline,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              GetBuilder<LoginController>(
                builder: (controller) => GlobalButton(
                  textButton: "login".tr,
                  isLoading: controller.statusRequest == StatusRequest.loading,
                  onPress: () => controller.login(),
                ),
              ),


              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                TextSignup(onTapFun: (){
                  controller.goToSignup();
                }),

                TextButton(onPressed: (){
                controller.goToForget();
                }, child: Text("forget_password".tr))


              ],)

            ],
          ),
        ),
      ),
    );
  }
}
