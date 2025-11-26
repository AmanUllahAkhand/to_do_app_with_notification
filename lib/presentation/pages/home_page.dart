import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/services/auth_service.dart';
import '../controllers/task_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/custom_button.dart';
import 'add_task_page.dart';

class HomePage extends StatelessWidget {
  final TaskController taskCtrl = Get.find();
  final ThemeController themeCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Obx(() => Icon(
                  Get.find<ThemeController>().isDarkMode.value
                      ? Icons.light_mode
                      : Icons.dark_mode,
                )),
                onPressed: () => Get.find<ThemeController>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await AuthService.logout();
                  Get.offAllNamed('/login');
                },
              )
            ],
          ),
        ],
      ),
      body: Obx(() {
        return ListView(
          children: [
            // Pending Tasks
            ...taskCtrl.tasks.map((task) => TaskCard(task: task)),
            const SizedBox(height: 20),
            const Text('Completed'),
            ...taskCtrl.completedTasks.map((task) => TaskCard(task: task)),
          ],
        );
      }),
      floatingActionButton: CustomButton(
        text: 'Add New Task',
        onPressed: () => Get.to(() => AddTaskPage()),
      ),
    );
  }
}