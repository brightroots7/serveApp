import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ExploreControllers extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController amountController = TextEditingController();
  final RxBool isProcessing = false.obs;
  final Map<DateTime, List<Map<String, dynamic>>> storedEvents = {};
  final RxList<Map<String, dynamic>> allEvents =
      RxList<Map<String, dynamic>>([]);

  final Map<DateTime, List<Map<String, dynamic>>> storedVolunteeringRequests =
      {};
  final RxList<Map<String, dynamic>> allVolunteeringRequests =
      RxList<Map<String, dynamic>>([]);
  var searchController = TextEditingController();

  final RxString searchQuery = ''.obs;
  var searchResults = <QueryDocumentSnapshot>[];
  Stream<QuerySnapshot> searchTemples(String query) {
    if (query.isEmpty) {
      return _firestore.collection('temples').snapshots();
    } else {
      return _firestore
          .collection('temples')
          .where('temple_name', isGreaterThanOrEqualTo: query)
          .where('temple_name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots();
    }
  }

//   Future<void> saveDonation(String templeId, double amount) async {
//     final user = FirebaseAuth.instance.currentUser;
//     await FirebaseFirestore.instance.collection('donations').add({
//       'amount': '\$${amount.toStringAsFixed(2)}',
//       'date_time': FieldValue.serverTimestamp(),
//       'eventName': 'Hawan',
//       'templeId': templeId,
//       'user_name': user?.displayName ?? 'Anonymous',
//       'payment_method': 'PayPal',
//     });
//   }
//
//   Future<void> initiatePayPalPayment(String templeId) async {
//     try {
//       isProcessing.value = true;
//       final amount = double.tryParse(amountController.text) ?? 0.0;
//
//       if (amount <= 0) {
//         throw "Invalid donation amount";
//       }
//
//       // Create PayPal order
//       final response = await http.post(
//         Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer YOUR_PAYPAL_CLIENT_TOKEN',
//         },
//         body: jsonEncode({
//           "intent": "CAPTURE",
//           "purchase_units": [
//             {
//               "amount": {
//                 "currency_code": "USD",
//                 "value": amount.toStringAsFixed(2),
//               },
//               "description": "Temple Donation"
//             }
//           ]
//         }),
//       );
//
//       final orderId = jsonDecode(response.body)['id'];
//
//       // Launch PayPal checkout
//       final result = await Navigator.of(Get.context!).push(
//         MaterialPageRoute(
//           builder: (context) => PayPalCheckout(
//             sandboxMode: true,
//             clientId: "AX0pRo50BLPiP4l0EQQLpsusqbnhAwCeB9yuhuF1W0ESDT5YczOyGupsmglXOJZ2ClyRl7zuIIR4m6fq",
//             secretKey: "EP5alWZc4hFgtpQZr74wgXCDn7R38El1SfYIQfVLSMqAP6nu9Zo5eK-l9lxZjOWc202LGJCP7_aq6s1_",
//             returnURL: 'https://mohanbright.github.io/QuickMROPayment/handlePaymentReturn.html',
//             cancelURL: 'https://mohanbright.github.io/QuickMROPayment/handlePaymentCancel.html',
//             transactions: [
//               {
//                 "amount": {
//                   "total": amount.toStringAsFixed(2),
//                   "currency": "USD",
//                 },
//                 "description": "Temple Donation",
//               }
//             ],
//             note: "Thank you for your donation!",
//           ),
//         ),
//       );
//
//       if (result['status'] == 'success') {
//         await saveDonation(templeId, amount);
//         Get.snackbar('Success', 'Donation completed!');
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isProcessing.value = false;
//     }
//
//
//
// }

  // ExploreControllers.dart
  void toggleFavorite(String templeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'You must be logged in to favorite temples');
      return;
    }

    final docRef =
        _firestore.collection('userFavorites').doc('${userId}_$templeId');
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'userId': userId,
        'templeId': templeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isFavoriteStream(String templeId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('userFavorites')
        .doc('${userId}_$templeId')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Add this method to store events
  void storeEvents(Map<DateTime, List<Map<String, dynamic>>> events) {
    storedEvents.clear();
    storedEvents.addAll(events);
    allEvents.value = events.values.expand((e) => e).toList();
    print('Stored ${allEvents.length} events in controller');
  }

  void storeVolunteering(
      Map<DateTime, List<Map<String, dynamic>>> volunteering) {
    storedVolunteeringRequests.clear();
    storedVolunteeringRequests.addAll(volunteering);
    allVolunteeringRequests.value =
        volunteering.values.expand((e) => e).toList();
    print('Stored ${allEvents.length} events in controller');
  }

  Stream<QuerySnapshot> getPopularTemples() {
    return _firestore
        .collection('temples')
        .where('type', isEqualTo: 'popular')
        .snapshots();
  }

  Stream<QuerySnapshot> getMustVisitTemples() {
    return _firestore
        .collection('temples')
        .where('type', isEqualTo: 'Must visit')
        .snapshots();
  }

  Stream<QuerySnapshot> gettemples() {
    print("Fetching temples...");
    return _firestore.collection('temples').snapshots();
  }

  Stream<QuerySnapshot> getDonations(String templeId) {
    return _firestore
        .collection('donations')
        .where('templeId', isEqualTo: templeId)
        .snapshots();
  }

  // Function to get Events for a particular temple
  Stream<QuerySnapshot> getEvents(String templeId) {
    return _firestore
        .collection('events')
        .where('templeId', isEqualTo: templeId)
        .snapshots();
  }

  // Function to get Volunteering Requests for a particular temple
  Stream<QuerySnapshot> getVolunteeringRequests(String templeId) {
    return _firestore
        .collection('volunteering request')
        .where('templeId', isEqualTo: templeId)
        .where('status', isEqualTo: 'Accepted')
        .snapshots();
  }

  // Function to get Services for a particular temple
  Stream<QuerySnapshot> getServices(String templeId) {
    return _firestore
        .collection('services')
        .where('templeId', isEqualTo: templeId)
        .snapshots();
  }

  Stream<QuerySnapshot> gettempledetails(String templeId) {
    return _firestore
        .collection('temples')
        .where('templeId', isEqualTo: templeId)
        .snapshots();
  }

  // Function to get Temple Details
  Stream<DocumentSnapshot> getTempleDetails(String templeId) {
    return _firestore.collection('temples').doc(templeId).snapshots();
  }
}
