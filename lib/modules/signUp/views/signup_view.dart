import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_loader/loaders/neon_grid_loader.dart';

import '../../../shared/Appcolors.dart';
import '../../login/views/login_view.dart';
import '../controllers/signup_controller.dart';


class SignupView extends GetView<SignupController> {
  SignupView({super.key});
  final controller = Get.put(SignupController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                Get.to(() => LoginView());
              },
              child: Text(
                "Log in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign up",
                style: GoogleFonts.rozhaOne(
                    fontSize: 32,
                    color: Appcolors.appColor,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: controller.firstnameController,
                decoration: InputDecoration(labelText: "First Name"),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: controller.lastnameController,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: controller.passwordController,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(
                height: 70,
              ),
              GestureDetector(
                onTap: () {
                  controller.signUp();
                },
                child: Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      color: Appcolors.appColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: controller.isLoading.value
                            ? NeonGridLoader(neonColor: Colors.amber,)
                            : Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Add this widget after the sign-up button in SignupView
              Obx(() => Text(
                controller.errorMessage.value,
                style: TextStyle(color: Colors.red),
              )),
              SizedBox(
                height: 20,
              ),
              Center(
                  child: Text(
                "OR",
                style: TextStyle(fontSize: 18, color: Appcolors.grey2),
              )),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Continue to Facebook',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: (Get.height) / 8,
              ),
              Center(
                  child: Text(
                "Terms of Use and Privacy Policy",
                style: TextStyle(fontSize: 18, color: Appcolors.grey2),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
