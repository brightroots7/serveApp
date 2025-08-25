import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:vibe_loader/loaders/neon_grid_loader.dart';

class Services extends GetView<ExploreControllers> {
  final String templeId;
  const Services({super.key, required this.templeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text("Temple Services", style: GoogleFonts.rozhaOne(color: Colors.amber)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("List of Services",style: TextStyle(color: Colors.amber,fontWeight: FontWeight.w700,fontSize: 28),),
            SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.getServices(templeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: NeonGridLoader(neonColor: Colors.amber,));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No services available'));
                  }

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),

                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final service = snapshot.data!.docs[index];
                      final data = service.data() as Map<String, dynamic>;

                      return ServiceTile(
                        title: data['serviceName'] ?? 'Unnamed Service',
                        subtitle: data['serviceDescription'] ?? 'No description',
                        imageUrl: data['img'] ?? '',
                        onTap: () => _showServiceDetails(context, data),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service['serviceName']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service['img'] != null && service['img'].isNotEmpty)
              Image.network(service['img']),
            SizedBox(height: 16),
            Text(service['serviceDescription']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const ServiceTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}