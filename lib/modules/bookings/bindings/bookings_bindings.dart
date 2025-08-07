import 'package:get/get.dart';

import '../controllers/bookings_controllers.dart';

class BookingsBindings extends Bindings{
  @override
  void dependencies() {
   Get.lazyPut<BookingsControllers>(()=>BookingsControllers());
  }

}