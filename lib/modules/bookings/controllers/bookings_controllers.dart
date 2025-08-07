import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/models.dart';

class BookingsControllers extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController tabController;
  var selectedTabIndex = 0.obs;
  var volunteeringRequests = <VolunteeringRequest>[].obs;
  var services = <Service>[].obs;
  var temples = <Temple>[].obs;


  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
    getVolunteeringRequest();
    getServicesAndTemples();
  }


  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> getServicesAndTemples() async {
    try {
      // Get all services
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      services.assignAll(
        servicesSnapshot.docs
            .map((doc) => Service.fromFirestore(doc))
            .toList(),
      );
      print('Fetched ${services.length} services');
      print('Fetched ${temples.length} temples');
      // Get unique temple IDs from services
      Set<String> templeIds = services.map((s) => s.templeId).toSet();

      if (templeIds.isNotEmpty) {
        // Get corresponding temples
        QuerySnapshot templesSnapshot = await FirebaseFirestore.instance
            .collection('temples')
            .where('templeId', whereIn: templeIds.toList())
            .get();

        temples.assignAll(
          templesSnapshot.docs
              .map((doc) => Temple.fromFirestore(doc))
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch services: ${e.toString()}');
    }
  }


  Future<void> getVolunteeringRequest() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('volunteering requests')
          .where('userId', isEqualTo: user.uid) // Filter by userId
          .get();

      volunteeringRequests.assignAll(
        querySnapshot.docs
            .map((doc) => VolunteeringRequest.fromFirestore(doc))
            .toList(),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch requests: ${e.toString()}');
    }
  }
}

