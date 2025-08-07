
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../modules/bookings/views/bookings_views.dart';
import '../modules/explore/views/explore_views.dart';
import '../modules/favourites/views/favourite_view.dart';
import '../modules/history/views/history_view.dart';
import '../modules/profile/views/profile_view.dart';
import 'Appcolors.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final TabController tabController = Get.put(TabController());

    return Scaffold(

      body: Obx(
            () {
              switch (tabController.selectedIndex.value) {
            case 0:
              return ExploreViews();
            case 1:
              return HistoryView();
            case 2:
              return BookingsViews();
            case 3:
              return FavouriteView();
            case 4:
              return  ProfileView();
            default:
              return ExploreViews();
          }
        },
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search,size: 24,),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded,size: 24,),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border,size: 24,),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border,size: 24,),
              label: 'Favourites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person,size: 24,),
              label: 'Profile',
            ),
          ],
          currentIndex: tabController.selectedIndex.value,
          onTap: tabController.onTabTapped,
          selectedItemColor: Appcolors.appColor,
          unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
        ),
      ),
    );
  }
}
class TabController extends GetxController {
  var selectedIndex = 0.obs;

  void onTabTapped(int index) {
    selectedIndex.value = index;
  }
}


