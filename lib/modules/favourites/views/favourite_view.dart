import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/favourites_controller.dart';

class FavouriteView extends GetView<FavouritesController> {
  FavouriteView({super.key});

  @override
  final controller = Get.put(FavouritesController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: (Get.height - 500) / 7,
              ),
             Text(
                "Favourites",
                style: GoogleFonts.rozhaOne(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: controller.getTemplesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var templeData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;
                      String imageUrl = "";
                      if (templeData['photos'] is List &&
                          templeData['photos'].isNotEmpty) {
                        imageUrl = templeData['photos'][0] ??
                            ''; // Take the first image from the array
                      } else {
                        imageUrl = ''; // Fallback if no image is available
                      }

                      return templeTile(
                        title: templeData['temple_name'] ?? 'No Name',
                        subtitle:
                            templeData['desc'] ?? 'Description not available',
                        imageUrl: imageUrl,
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class templeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const templeTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin for spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2, // 40% of available width
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AspectRatio(
                aspectRatio: 1, // Square image
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : const AssetImage('assets/placeholder_image.png')
                      as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3, // 60% of available width
            child: Padding(
              padding: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity, // Constrain text width
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}