import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:serveapp/shared/chatScreen.dart';

import '../../../shared/donations.dart';
import '../../../shared/events.dart';
import '../../../shared/services.dart';
import '../../../shared/volunteering.dart';
import 'package:vibe_loader/vibe_loader.dart';

class TempleDetailView extends GetView<ExploreControllers> {
  final String templeId;
  TempleDetailView({required this.templeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Temple Details",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                print("TempleId from detail: '${templeId}'");

                // First try with direct query
                var adminSnapshot = await FirebaseFirestore.instance
                    .collection('temple_admin')
                    .where('templeId', isEqualTo: templeId.trim())
                    .limit(1)
                    .get();

                if (adminSnapshot.docs.isEmpty) {
                  // Fallback: fetch all admins and match manually
                  final allAdmins = await FirebaseFirestore.instance
                      .collection('temple_admin')
                      .get();

                  // Filter documents manually
                  final matchingDocs = allAdmins.docs.where((doc) =>
                  doc['templeId'].toString().trim() == templeId.trim()).toList();

                  if (matchingDocs.isNotEmpty) {
                    final adminData = matchingDocs.first.data();
                    final templeAdminId = adminData['temple_admin_uid'];
                    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                    Get.to(() => Chatscreen(
                      currentUserId: currentUserId,
                       templeAdminId: templeAdminId,
                    ));
                  } else {
                    Get.snackbar("Error", "Temple admin not found");
                  }
                } else {
                  // Use the document from the initial query
                  final adminData = adminSnapshot.docs.first.data();
                  final templeAdminId = adminData['temple_admin_uid'];
                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  Get.to(() => Chatscreen(
                    currentUserId: currentUserId,
              templeAdminId: templeAdminId,
                  ));
                }
              } catch (e) {
                Get.snackbar("Error", "Failed to fetch temple admin: $e");
              }
            },
            icon: Icon(Icons.chat, color: Colors.amber),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: controller.getTempleDetails(templeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: BouncingDotsLoader(
                color: Colors.amber,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading temple details'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Temple not found'));
          }

          var temple = snapshot.data!;
          var templeData = temple.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Main Image
                Container(
                  height: Get.height / 3,
                  width: Get.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        templeData['photos']?.isNotEmpty == true
                            ? templeData['photos'][0]
                            : 'https://via.placeholder.com/400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Temple Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            templeData['temple_name'] ?? 'Temple',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          StreamBuilder<bool>(
                            stream: controller.isFavoriteStream(templeId),
                            builder: (context, snapshot) {
                              bool isFavorite = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                  isFavorite ? Colors.red : Colors.blueGrey,
                                ),
                                onPressed: () =>
                                    controller.toggleFavorite(templeId),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        templeData['desc'] ?? 'No description available',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),

                      Text("Photos", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      _buildPhotosGallery(templeData['photos'] ?? []),
                      const SizedBox(height: 20),

                      Text("Services", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      _buildServicesGrid(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotosGallery(List<dynamic> photos) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(photos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildServiceButton("Volunteering", Icons.people),
        _buildServiceButton("Events", Icons.event),
        _buildServiceButton("Services", Icons.miscellaneous_services),
        _buildServiceButton("Donations", Icons.volunteer_activism),
      ],
    );
  }

  Widget _buildServiceButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        print(templeId);
        if (title == "Volunteering") {
          Get.to(() => Volunteering(
            templeId: templeId,
          ));
        } else if (title == "Events") {
          Get.to(() => Events(
            templeId: templeId,
          ));
        } else if (title == "Services") {
          Get.to(() => Services(
            templeId: templeId,
          ));
        } else if (title == "Donations") {
          Get.to(() => Donations(
            templeId: templeId,
          ));
        } else {
          Get.snackbar(title, "Failed to navigate..");
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.amber,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }
}
