import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:serveapp/modules/explore/views/templeDetails.dart';
import '../../../shared/Appcolors.dart';

class ExploreViews extends GetView<ExploreControllers> {
  ExploreViews({super.key});
  @override
  final controller = Get.put(ExploreControllers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (kDebugMode) {
            print("Back pressed");
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Header Section with Search Results
                Container(
                  height: Get.height / 2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/temple.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.03),
                        _buildSearchBar(),
                        Obx(() => controller.searchQuery.value.isNotEmpty
                            ? _buildHeaderSearchResults()
                            : SizedBox.shrink()),
                        Spacer(),
                        Text("Explore",
                            style: TextStyle(fontSize: 42, color: Colors.white)),
                        Text("near temples",
                            style: TextStyle(fontSize: 42, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text("Popular Temples", style: TextStyle(fontSize: 28)),
                    ),
                    _buildPopularTemples(),
                    Padding(
                      padding: const EdgeInsets.only(left: 18, top: 10),
                      child: Text("Must Visit", style: TextStyle(fontSize: 28)),
                    ),
                    _buildMustVisitTemples(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: (Get.height-400)/9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller.searchController,
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
           hintText: 'Search Temples',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ),
          onChanged: (query) => controller.searchQuery.value = query,
        ),
      ),
    );
  }

  Widget _buildHeaderSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.searchTemples(controller.searchQuery.value),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return SizedBox.shrink();

        return Container(
          height: Get.height * 0.2,
          margin: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              final temple = snapshot.data!.docs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      temple['photos']?.isNotEmpty == true
                          ? temple['photos'][0]
                          : 'https://via.placeholder.com/150'),
                ),
                title: Text(temple['temple_name']),
                onTap: () => Get.to(() => TempleDetailView(templeId: temple.id)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularTemples() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getPopularTemples(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Container(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var temple = snapshot.data!.docs[index];
              String imageUrl = temple['photos']?.isNotEmpty == true
                  ? temple['photos'][0]
                  : 'https://via.placeholder.com/150';

              return GestureDetector(
                onTap: () => Get.to(() => TempleDetailView(templeId: temple.id)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: Get.width / 1.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMustVisitTemples() {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getMustVisitTemples(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var temple = snapshot.data!.docs[index];
            String imageUrl = temple['photos']?.isNotEmpty == true
                ? temple['photos'][0]
                : 'https://via.placeholder.com/150';

            return GestureDetector(
              onTap: () => Get.to(() => TempleDetailView(templeId: temple.id)),
              child: Container(
                decoration: BoxDecoration(
                  color: Appcolors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                margin: EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(temple['temple_name'] ?? 'Temple',
                              style: TextStyle(fontSize: 18)),
                          Text(temple['desc'] ?? 'Description',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MustVisitTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const MustVisitTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(color: Appcolors.white, boxShadow: [
          new BoxShadow(
            color: Colors.black,
            blurRadius: 3.0,
          ),
        ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // In MustVisitTile class:
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect( // Add this
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage('assets/placeholder_image.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 3, // 60% of available width
              child: Padding(
                padding: EdgeInsets.only(right: 12, top: 12, bottom: 12),
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
                          fontSize: 18,
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
      ),
    );
  }
}
