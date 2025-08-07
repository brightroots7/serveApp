import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/bookings_controllers.dart';

class BookingsViews extends GetView<BookingsControllers> {
  BookingsViews({super.key});

  @override
  final controller = Get.put(BookingsControllers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: (Get.height - 500) / 8,
          ),
          Center(
            child: Text(
              "My Bookings",
              style: GoogleFonts.rozhaOne(fontSize: 26, color: Colors.black),
            ),
          ),
          SizedBox(
            height: (Get.height - 500) / 9,
          ),
          TabBar(
            controller: controller.tabController,
            indicatorColor: Colors.amber,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Services',),
              Tab(text: 'Volunteering'),
            ],
            onTap: (index) => controller.selectedTabIndex.value = index,
          ),
          // Add Tab content
          Expanded(
            child: Obx(() => IndexedStack(
              index: controller.selectedTabIndex.value,
              children: [
                // Services Tab Content
                _buildServicesContent(),
                _buildVolunteeringContent(),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    return Obx(() {
      if (controller.services.isEmpty) {
        return const Center(child: Text("No services found"));
      }
      return ListView.builder(
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];
          final temple = controller.temples.firstWhereOrNull(
                (t) => t.templeId == service.templeId,
          );
          print('Service TempleID: ${service.templeId}');
          print('Matched Temple: ${temple?.templeId}');
          print('Photos available: ${temple?.photos.length}');
          return Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 3)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (temple != null && temple.photos.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      temple.photos.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 12),
                Text(
                  service.serviceName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  service.serviceDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                if (temple != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        temple.templeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    });
  }





  Widget _buildVolunteeringContent() {
    return Obx(() {
      if (controller.volunteeringRequests.isEmpty) {
        return const Center(child: Text("No volunteering requests found"));
      }
      return ListView.builder(
        itemCount: controller.volunteeringRequests.length,
        itemBuilder: (context, index) {
          final request = controller.volunteeringRequests[index];
          Color statusColor = _getStatusColor(request.status);

          return Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 3)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.eventName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(request.festivalName,
                    style: TextStyle(color: Colors.grey[600],fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Status: ",style: TextStyle(color: Colors.grey[600],fontSize: 16)),
                    Text(request.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold,fontSize: 16)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(request.dateTime),
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default: // Requested or other
        return Colors.amber;
    }
  }
}