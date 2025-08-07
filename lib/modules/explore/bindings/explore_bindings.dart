import 'package:get/get.dart';

import '../controllers/explore_controllers.dart';


class ExploreBindings extends Bindings{
  @override
  void dependencies() {
   Get.lazyPut<ExploreControllers>(()=> ExploreControllers());
  }

}