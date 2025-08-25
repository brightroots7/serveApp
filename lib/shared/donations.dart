import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serveapp/modules/explore/controllers/explore_controllers.dart';
import 'package:serveapp/shared/paypalPayment.dart';
import 'package:vibe_loader/loaders/pulse_loader.dart';

import 'Appcolors.dart';

class Donations extends GetView<ExploreControllers> {
  final String templeId;
  Donations({super.key, required this.templeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Donations",
          style: TextStyle(
              color: Colors.amber, fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Donations for the trust",
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.amber,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: controller
                    .getTempleDetails(templeId), // Use getTempleDetails instead
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: PulseLoader(color: Colors.amber,));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading temple details'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('Temple not found'));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return DonationTile(
                    title: data['temple_name'] ?? 'Unnamed Temple',
                    subtitle: data['desc'] ?? 'No description available',
                    imageUrl:
                        (data['photos'] is List && data['photos'].isNotEmpty)
                            ? data['photos'][0]
                            : 'https://via.placeholder.com/150',
                    onTap: () {},
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: "Amount"),
                controller: controller.amountController,
              ),
              SizedBox(height: (Get.height) / 3),
              GestureDetector(
                onTap: () async {
                  Get.to(() => PaypalPaymentScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Appcolors.appColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:

                          Text(
                        'Proceed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const DonationTile({
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
              SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
