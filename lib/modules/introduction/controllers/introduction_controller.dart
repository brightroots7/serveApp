import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class IntroductionController extends GetxController {
  var currentPage = 0.obs; // The current page number
  final PageController pageController = PageController(); // The controller for PageView

  // Method to update the current page index
  void updatePage(int index) {
    currentPage.value = index;
  }

  // Method to go to the next page
  void goToNextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
      pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  // Method to go to the previous page
  void goToPreviousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }
}
