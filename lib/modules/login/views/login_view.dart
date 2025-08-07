import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serveapp/modules/login/views/forgot_view.dart';
import '../../../shared/Appcolors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  @override
  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Log in",
                style: GoogleFonts.rozhaOne(
                    fontSize: 32,
                    color: Appcolors.appColor,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  suffixIcon: Icon(Icons.email_outlined),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(() => TextFormField(
                    controller: controller.passwordController,
                    obscureText: !controller.passwordVisible
                        .value, // Bind obscureText to passwordVisible
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.passwordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: controller
                            .togglePasswordVisibility, // Toggle password visibility
                      ),
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ForgotView());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 70,
              ),
              GestureDetector(
                onTap: () async {
                  await controller.login();
                },
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: Appcolors.appColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Log in',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
