import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serveapp/modules/login/views/login_view.dart';

class ProfileController extends GetxController{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  RxBool isChangingPassword = false.obs;

  var displayName = ''.obs;
  var profileImageUrl = ''.obs;
  var email = ''.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }




  Future<void> changePassword() async {
    try {
      isChangingPassword.value = true;
      final user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      // Validate form
      if (newPasswordController.text != confirmPasswordController.text) {
        throw "Passwords do not match";
      }

      // Reauthenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPasswordController.text);

      // Clear fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.back();
      Get.snackbar(
        'Success!',
        'Password updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Password change failed';
      if (e.code == 'wrong-password') {
        message = 'Incorrect current password';
      } else if (e.code == 'requires-recent-login') {
        message = 'This operation requires recent authentication. Please log in again.';
      }
      Get.snackbar('Error', message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        displayName.value = userDoc.get('display_name') ?? '';
        profileImageUrl.value = userDoc.get('image_url') ?? '';
        email.value = userDoc.get('email') ?? user.email ?? 'No email available';
      }
    }
  }

  Future<void> updateProfile(String newName, String imageUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'display_name': newName,
        'image_url': imageUrl,
      });
      displayName.value = newName;
      profileImageUrl.value = imageUrl;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    User? user = _auth.currentUser;
    if (user == null) return '';
    try {
      Reference ref = _storage.ref().child('profile_images/${user.uid}');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image');
      return '';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      Get.offAll(() => LoginView());
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}