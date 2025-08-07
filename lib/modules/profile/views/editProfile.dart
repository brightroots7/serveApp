import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/profile_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileController controller = Get.find();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: controller.displayName.value);
    _emailController = TextEditingController(text: controller.email.value);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    String newName = _nameController.text;
    String newImageUrl = controller.profileImageUrl.value;

    if (_pickedImage != null) {
      newImageUrl = await controller.uploadImage(_pickedImage!);
    }

    await controller.updateProfile(newName, newImageUrl);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile',style: TextStyle(color: Colors.amber,fontSize: 24,fontWeight: FontWeight.w700),),centerTitle: true, actions: [
        GestureDetector(
          onTap: _saveProfile,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: (Get.height-500)/9,
             width: (Get.width)/5,
             
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w500),
                    ),
                  ),
                )),
          ),
        )
      ]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _getImage(),
                child: Icon(Icons.edit, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImage() {
    if (_pickedImage != null) return FileImage(_pickedImage!);
    if (controller.profileImageUrl.value.isNotEmpty) {
      return NetworkImage(controller.profileImageUrl.value);
    }
    return AssetImage("assets/images/placeholder.jpg");
  }
}
