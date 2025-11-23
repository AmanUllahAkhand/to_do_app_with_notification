import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../pages/add_task_page.dart';
import 'category_icon.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({Key? key, required this.task}) : super(key: key); // ← Remove 'const' only if needed elsewhere

  // We'll get the controller inside build() instead of as a field
  @override
  Widget build(BuildContext context) {
    final TaskController ctrl = Get.find<TaskController>(); // ← Move here

    // Helper to parse date + time correctly
    String _formatDateTime() {
      try {
        final dateStr = task.date.toIso8601String().split('T').first;
        final timeStr = task.time.trim();

        // Handle both 12-hour (10:25 PM) and 24-hour formats
        final DateTime fullDateTime;
        if (timeStr.contains('AM') || timeStr.contains('PM')) {
          fullDateTime = DateFormat('yyyy-MM-dd h:mm a').parse('$dateStr $timeStr');
        } else {
          fullDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$dateStr $timeStr');
        }
        return DateFormat('h:mm a').format(fullDateTime);
      } catch (e) {
        return task.time;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CategoryIcon(category: task.category),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (task.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.notes,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.purple,
          onChanged: (bool? value) {
            if (value == true) {
              ctrl.markComplete(task);
            }
          },
        ),
        onTap: () {
          Get.to(() => AddTaskPage(task: task));
        },
        onLongPress: () {
          Get.defaultDialog(
            title: "Delete Task",
            middleText: "Are you sure you want to delete this task?",
            textConfirm: "Delete",
            textCancel: "Cancel",
            confirmTextColor: Colors.white,
            onConfirm: () {
              ctrl.delete(task);
              Get.back();
            },
          );
        },
      ),
    );
  }
}