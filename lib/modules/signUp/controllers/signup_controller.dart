import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/homeScreen.dart';

class SignupController extends GetxController{


final TextEditingController firstnameController = TextEditingController();
final TextEditingController lastnameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

final _auth = FirebaseAuth.instance;
RxString errorMessage = ''.obs;

RxBool isLoading = false.obs;


// Correct the validation logic in signUp method
  Future<void> signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty) {
      errorMessage.value = "Email is empty!";
      return;
    }

    if (password.isEmpty) {
      errorMessage.value = "Password is empty!";
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update user profile
      await userCredential.user?.updateDisplayName(
        '${firstnameController.text} ${lastnameController.text}',
      );


      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'display_name':firstnameController.text + lastnameController.text,
        'email': email,
        'uid':userCredential.user?.uid,
        'status':"Active",
        "created_time":Timestamp.now(),

      });

      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'An error occurred';
    } finally {
      isLoading.value = false;
    }
  }
}