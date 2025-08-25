import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vibe_loader/loaders/neon_grid_loader.dart';

import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  HistoryView({super.key});
  @override
  final controller = Get.put(HistoryController());

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
                "Donation History",
                style: GoogleFonts.rozhaOne(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: controller.getDonationHistory(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: NeonGridLoader(neonColor: Colors.amber,));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var donationData = snapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      String name = donationData['user_name'] ?? "No name";
                      String eventName = donationData['eventName'];
                      String amount = donationData['amount'];
                      Timestamp time_date = donationData['date_time'];
                      DateTime dateTime = time_date.toDate();
                      String formattedDate =
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.green,
                            size: 30,
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text(eventName), Text(formattedDate)],
                          ),
                          trailing: Text(
                            amount,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
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
