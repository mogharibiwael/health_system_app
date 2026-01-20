import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';
import 'package:nutri_guide/feature/auth/widget/logo_auth.dart';
import '../../../core/class/status_request.dart';
import '../../../core/shared/widgets/global_button.dart';
import '../../../core/shared/widgets/text_form_field.dart';
import '../widget/dropdown_button_formField.dart';

class Signup extends GetView<SignupController> {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text("signupTitle".tr),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const LogoAuth(),
              const SizedBox(height: 20),

              // name
              CustomTextFormField(
                controller: c.nameController,
                keyboardType: TextInputType.text,
                label: "name".tr,
                hintText: "enterName".tr,
                icon: Icons.person_outline,
                obscureText: false,
              ),

              // email
              CustomTextFormField(
                controller: c.emailController,
                keyboardType: TextInputType.emailAddress,
                label: "email".tr,
                hintText: "enterEmail".tr,
                icon: Icons.email_outlined,
                obscureText: false,
              ),

              // phone
              CustomTextFormField(
                controller: c.phoneController,
                keyboardType: TextInputType.phone,
                label: "phoneOptional".tr,
                hintText: "enterPhone".tr,
                icon: Icons.phone_outlined,
                obscureText: false,
              ),

              const SizedBox(height: 12),

              // role
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "roleOptional".tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 6),
              RoleDropdown(
                value: c.selectedRole,
                items: c.roleItems,
                enabled: c.statusRequest != StatusRequest.loading,
                onChanged: (v) {
                  c.selectedRole = v; // ممكن null
                  c.update();
                },
              ),


              const SizedBox(height: 12),

              // password
              CustomTextFormField(
                controller: c.passwordController,
                keyboardType: TextInputType.text,
                label: "password".tr,
                hintText: "passwordHint".tr,
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              // confirm password
              CustomTextFormField(
                controller: c.confirmPasswordController,
                keyboardType: TextInputType.text,
                label: "confirmPassword".tr,
                hintText: "confirmPasswordHint".tr,
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 16),

              GlobalButton(
                textButton: "signupButton".tr,
                onPress: () => c.register(),
              ),

              const SizedBox(height: 24),

              TextButton(onPressed: (){
                controller.goToLogin();
              }, child: Text("login".tr))

            ],
          ),
        ),
      ),
    );
  }
}
