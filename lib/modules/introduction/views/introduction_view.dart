import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../shared/Appcolors.dart';
import '../controllers/introduction_controller.dart';
import 'intro.dart';

class IntroductionView extends GetView<IntroductionController> {
  final controller = Get.put(IntroductionController());

  final List<Widget> _pages = [
    PageContent(
      imageUrl: 'assets/images/temple1.jpeg',
      pageText: 'Sanctuary',
      pageSubText: 'A selection of religious sanctuaries verified for you.',
    ),
    PageContent(
      imageUrl: 'assets/images/temple3.jpeg',
      pageText: 'Fast Booking',
      pageSubText: 'Save your payment details for secure bookings.',
    ),
    PageContent(
      imageUrl: 'assets/images/temple4.webp',
      pageText: 'Organized',
      pageSubText: 'Easily navigate to find what you need from services, scheduled events, volunteering and much more!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePage,
              children: _pages,
            ),
          ),
          // SmoothPageIndicator is wrapped with Obx to reactively update the page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child:  SmoothPageIndicator(
                controller: controller.pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 12.0,
                  dotWidth: 12.0,
                  spacing: 8.0,
                  expansionFactor: 4,
                  dotColor: Colors.grey,
                  activeDotColor: Appcolors.appColor,
                ),
              ),
            ),

        ],
      ),
    );
  }
}

class PageContent extends StatelessWidget {
  final String imageUrl;
  final String pageText;
  final String pageSubText;

  const PageContent({
    super.key,
    required this.imageUrl,
    required this.pageText,
    required this.pageSubText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image at the top
        Center(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height * 0.9,
          ),
        ),
        // Container at the bottom with text and button
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pageText,
                  style: GoogleFonts.rozhaOne(
                      fontSize: 46,
                      color: Appcolors.appColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    pageSubText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(()=>Intro());
                  },

                  child: Container(
                    width: (Get.width-20),
                    decoration: BoxDecoration(
                      color: Appcolors.appColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
