import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serveapp/modules/profile/controllers/profile_controller.dart';

class SettingsView extends GetView<ProfileController> {
  SettingsView({super.key});
  final controller = Get.put(ProfileController());

  // Show Terms/Privacy dialog
  void _showPolicyDialog(String title, String content) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 300, // Fixed height for scrollable content
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(150, 45),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Agree',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 34,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
            ),
            SizedBox(width: 15),

            // Notifications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notifications", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(onPressed: () {}, icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey))
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),

            // City
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("City", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(onPressed: () {}, icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey))
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),

            // Terms of Services
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Terms of Services", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(
                  onPressed: () {
                    _showPolicyDialog(
                        "Terms of Service",
                        "Welcome to our app. By using our services, you agree to comply with and be bound by the following terms:\n\n"
                            "1. User Responsibilities:\n"
                            "- You are responsible for keeping your account secure.\n"
                            "- Do not misuse or exploit the service.\n\n"
                            "2. Service Limitations:\n"
                            "- We may update or remove services at any time.\n\n"
                            "3. Termination:\n"
                            "- We can suspend or terminate accounts if terms are violated.\n\n"
                            "See full details on our website."
                    );
                  },
                  icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey),
                )
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),

            // Privacy Policy
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Privacy Policy", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(
                  onPressed: () {
                    _showPolicyDialog(
                        "Privacy Policy",
                        "We value your privacy. Here's how we manage your information:\n\n"
                            "- Collected: Name, email, usage, device data\n"
                            "- Usage: Improve experience, ensure security\n"
                            "- We do not sell your data\n\n"
                            "Review our complete privacy policy on the official site."
                    );
                  },
                  icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey),
                )
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),

            // Feedback
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Give Feedbacks", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(onPressed: () {}, icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey))
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),

            // Logout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Log Out", style: TextStyle(fontSize: 19, color: Colors.grey)),
                IconButton(
                  onPressed: () {
                    Get.dialog(
                      Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Container(
                          height: 250,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Logout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Are you sure you want to sign out?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(100, 45),
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () async {
                                      controller.signOut();
                                      Get.back();
                                    },
                                    child: Text('Yes', style: TextStyle(fontSize: 18, color: Colors.white)),
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(minimumSize: Size(100, 45)),
                                    onPressed: () => Get.back(),
                                    child: Text('Cancel', style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.chevron_right, size: 24, color: Colors.grey),
                )
              ],
            ),
            Padding(padding: const EdgeInsets.all(4.0), child: Divider()),
          ],
        ),
      ),
    );
  }
}
