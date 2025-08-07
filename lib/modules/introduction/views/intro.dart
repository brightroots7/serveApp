import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/Appcolors.dart';
import '../../login/views/login_view.dart';
import '../../signUp/views/signup_view.dart';
import '../controllers/introduction_controller.dart';


class Intro extends GetView<IntroductionController> {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  "assets/images/temple2.jpeg",
                ),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: (Get.height - 250) / 6,
                ),
                Text(
                  "SERVE",
                  style: TextStyle(
                      color: Appcolors.appColor,
                      fontSize: 52,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: (Get.height) / 1.7,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => SignupView());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: (Get.height - 500) / 9),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account? ",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      GestureDetector(
                          onTap: () {
                            Get.to(() => LoginView());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Log In",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
