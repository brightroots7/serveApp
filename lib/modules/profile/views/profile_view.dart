import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:serveapp/modules/profile/views/editProfile.dart';
import 'package:serveapp/modules/profile/views/settings.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/profile_controller.dart';
import 'changePassword.dart';

class ProfileView extends GetView<ProfileController> {
   ProfileView({super.key});
@override
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15,),
              Row(
                children: [
                  SizedBox(
                    height: (Get.height - 500) / 8,
                  ),
                  Flexible(
                    child: Obx(
                      ()=> Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.displayName.value,
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 34,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            controller.email.value,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
          
                        ],
                      )),
                  ),
                  SizedBox(width: 30,),
                  Obx(() => Container(
                    height: Get.height / 5,
                    width: Get.height / 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: controller.profileImageUrl.value.isNotEmpty
                            ? NetworkImage(controller.profileImageUrl.value)
                            : AssetImage("assets/images/temple.jpg") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
                ],
              ),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("Edit Profile",style: TextStyle(fontSize: 19,color: Colors.grey),),
                IconButton(onPressed: (){
                  Get.to(()=>EditProfile());
                }, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
              ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change Password",style: TextStyle(fontSize: 19,color: Colors.grey),),
                  IconButton(onPressed: (){
                    Get.to(() => ChangePasswordView());
                  }, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
                ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Invite Friends",style: TextStyle(fontSize: 19,color: Colors.grey),),
                  IconButton(onPressed: (){
                    Share.share(
                      'Hey! 👋 I’m using this awesome app and thought you might like it too! Download it from here: https://yourapp.link/download',
                      subject: 'Check out this amazing app!',
                    );
                  }, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
                ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Help & Supports",style: TextStyle(fontSize: 19,color: Colors.grey),),
                  IconButton(onPressed: (){}, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
                ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Payments",style: TextStyle(fontSize: 19,color: Colors.grey),),
                  IconButton(onPressed: (){}, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
                ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Settings",style: TextStyle(fontSize: 19,color: Colors.grey),),
                  IconButton(onPressed: (){
                    Get.to(()=>SettingsView());
                  }, icon: Icon(Icons.chevron_right,size: 24,color: Colors.grey,))
                ],),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Divider(),
              ),
              ],
              ),
        ),),
    );
  }
}
