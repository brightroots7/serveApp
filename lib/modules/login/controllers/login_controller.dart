import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/homeScreen.dart';

class LoginController extends GetxController {
  final passwordVisible = false.obs;
  RxBool isLoading = false.obs;
  RxBool isResettingPassword = false.obs;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> resetPassword() async {
    try {
      isResettingPassword.value = true;
      final email = emailController.text.trim();

      if (email.isEmpty) {
        throw "Please enter your email address";
      }
      if (!GetUtils.isEmail(email)) {
        throw "Please enter a valid email address";
      }

      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        "Success!",
        "Password reset instructions sent to $email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? "Unknown error occurred";
      Get.snackbar("Error", message.replaceAll("-", " ").capitalize!);
    } catch (e) {
      Get.snackbar("Error", e.toString().capitalize!);
    } finally {
      isResettingPassword.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoading.value = true;

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      final fcmToken = await getToken();
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        final userDoc =
            _firestore.collection('users').doc(userCredential.user!.uid);
        await userDoc.update({'fcmToken': fcmToken});
      }
      Get.to(() => HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
