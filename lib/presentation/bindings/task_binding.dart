import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../controllers/theme_controller.dart';

class TaskBinding implements Bindings {
  @override
  void dependencies() {
    // Permanent = true → keeps controller alive even after page is closed
    Get.put(TaskController(), permanent: true);
    Get.lazyPut<ThemeController>(() => ThemeController());
  }
}