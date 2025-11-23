// lib/presentation/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../pages/add_task_page.dart';
import 'category_icon.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController ctrl = Get.find<TaskController>();

    // Safely format time (12-hour format with AM/PM)
    String _formatTime() {
      try {
        final timeStr = task.time.trim();
        if (timeStr.contains('AM') || timeStr.contains('PM')) {
          return timeStr; // Already in 12-hour format
        } else {
          // Convert 24-hour to 12-hour
          final parsed = DateFormat('HH:mm').parse(timeStr);
          return DateFormat('h:mm a').format(parsed);
        }
      } catch (e) {
        return task.time;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CategoryIcon(category: task.category),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
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
                  _formatTime(),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            if (task.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.notes,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.purple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (bool? value) {
            if (value == true) {
              // Mark as completed
              ctrl.markComplete(task);
            } else {
              // Uncheck → move back to To Do list
              ctrl.unmarkComplete(task);
            }
          },
        ),
        onTap: () {
          Get.to(() => AddTaskPage(task: task));
        },
        onLongPress: () {
          Get.defaultDialog(
            title: "Delete Task",
            middleText: "Are you sure you want to delete \"${task.title}\"?",
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