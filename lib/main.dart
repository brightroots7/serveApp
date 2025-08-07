import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:serveapp/modules/introduction/views/introduction_view.dart';
import 'package:serveapp/shared/homeScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe.publishableKey = 'pk_test_51OV9dBSBOOhIel5em9yEers7yRtAr7ES0Vygdw7jkBiBgq6wCvL4fvJtQ2uvn16IAz4bTK3EJH2WCldaGnmGnD6S00RKRezjuS';
  // await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use AndroidProvider.playIntegrity for release
    appleProvider: AppleProvider.debug, // Use AppleProvider.appAttest for release
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Serve App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return HomeScreen(); // Your existing home screen
          }

          return IntroductionView();
        },
      ),
    );
  }
}