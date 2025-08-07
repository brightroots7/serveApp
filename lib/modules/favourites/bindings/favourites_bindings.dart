import 'package:get/get.dart';

import '../controllers/favourites_controller.dart';


class FavouritesBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<FavouritesController>(()=>FavouritesController());
  }

}