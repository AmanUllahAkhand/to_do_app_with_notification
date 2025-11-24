// lib/presentation/pages/add_task_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/utils/notification_helper.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/category_icon.dart';

class AddTaskPage extends StatefulWidget {
  final TaskEntity? task;
  const AddTaskPage({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late TextEditingController titleCtrl;
  late TextEditingController notesCtrl;
  late RxString selectedCategory;
  late Rx<DateTime> selectedDate;
  late Rx<TimeOfDay> selectedTimeOfDay;
  late RxBool hasReminder;
  // late Rx<TaskPriority> selectedPriority; // ← Re-enabled

  final TaskController ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    notesCtrl = TextEditingController(text: widget.task?.notes ?? '');

    selectedCategory = (widget.task?.category ?? 'home').obs;
    selectedDate = (widget.task?.date ?? DateTime.now()).obs;

    final savedTimeStr = widget.task?.time ?? '10:00 AM';
    selectedTimeOfDay = _parseTimeString(savedTimeStr).obs;

    hasReminder = (widget.task?.hasReminder ?? false).obs;
    // selectedPriority = (widget.task?.priority ?? TaskPriority.medium).obs;
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final format = timeStr.contains('AM') || timeStr.contains('PM')
          ? DateFormat('h:mm a')
          : DateFormat('HH:mm');
      final dateTime = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 20),

              // Category Selection
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryIcon(category: 'home', isSelected: selectedCategory.value == 'home', onTap: () => selectedCategory.value = 'home'),
                  CategoryIcon(category: 'shopping', isSelected: selectedCategory.value == 'shopping', onTap: () => selectedCategory.value = 'shopping'),
                  CategoryIcon(category: 'work', isSelected: selectedCategory.value == 'work', onTap: () => selectedCategory.value = 'work'),
                  CategoryIcon(category: 'personal', isSelected: selectedCategory.value == 'personal', onTap: () => selectedCategory.value = 'personal'),
                ],
              )),
              const SizedBox(height: 20),

              // Priority Selection
              // Text("Priority", style: Theme.of(context).textTheme.titleMedium),
              // const SizedBox(height: 8),
              // Obx(() => Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     _priorityChip("High", TaskPriority.high, Colors.red.shade400),
              //     _priorityChip("Medium", TaskPriority.medium, Colors.orange.shade600),
              //     _priorityChip("Low", TaskPriority.low, Colors.green.shade600),
              //   ],
              // )),
              const SizedBox(height: 20),

              // Date Picker
              Obx(() => ListTile(
                title: Text('Date: ${DateFormat('MMM d, yyyy').format(selectedDate.value)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) selectedDate.value = date;
                },
              )),

              // Time Picker
              Obx(() => ListTile(
                title: Text('Time: ${_formatTime(selectedTimeOfDay.value)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTimeOfDay.value,
                  );
                  if (time != null) selectedTimeOfDay.value = time;
                },
              )),

              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              Obx(() => CheckboxListTile(
                title: const Text('Set Reminder'),
                value: hasReminder.value,
                onChanged: (val) => hasReminder.value = val!,
              )),

              const SizedBox(height: 30),

              CustomButton(
                text: widget.task == null ? 'Save' : 'Update',
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Title is required',
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  final timeString = _formatTime(selectedTimeOfDay.value);
                  final reminderTime = DateTime(
                    selectedDate.value.year,
                    selectedDate.value.month,
                    selectedDate.value.day,
                    selectedTimeOfDay.value.hour,
                    selectedTimeOfDay.value.minute,
                  );

                  if (widget.task == null) {
                    // ADD NEW TASK
                    final newTaskId = await ctrl.addNewTask(
                      title: titleCtrl.text.trim(),
                      category: selectedCategory.value,
                      date: selectedDate.value,
                      time: timeString,
                      notes: notesCtrl.text,
                      hasReminder: hasReminder.value,
                      // priority: selectedPriority.value, // ← Fixed
                    );

                    if (hasReminder.value && reminderTime.isAfter(DateTime.now())) {
                      await NotificationHelper.scheduleReminder( // ← Fixed method name
                        id: newTaskId,
                        title: "Reminder",
                        body: titleCtrl.text.trim(),
                        dateTime: reminderTime,
                      );
                    }
                  } else {
                    // UPDATE EXISTING TASK
                    final updatedTask = TaskEntity(
                      id: widget.task!.id,
                      title: titleCtrl.text.trim(),
                      category: selectedCategory.value,
                      date: selectedDate.value,
                      time: timeString,
                      notes: notesCtrl.text,
                      isCompleted: widget.task!.isCompleted,
                      hasReminder: hasReminder.value,
                      // priority: selectedPriority.value,
                    );

                    await ctrl.updateExistingTask(updatedTask);

                    if (widget.task!.hasReminder) {
                      await NotificationHelper.cancel(widget.task!.id!);
                    }

                    if (hasReminder.value && reminderTime.isAfter(DateTime.now())) {
                      await NotificationHelper.scheduleReminder(
                        id: widget.task!.id!,
                        title: "Reminder",
                        body: titleCtrl.text.trim(),
                        dateTime: reminderTime,
                      );
                    }
                  }

                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _priorityChip(String label, TaskPriority priority, Color color) {
  //   final isSelected = selectedPriority.value == priority;
  //   return GestureDetector(
  //     onTap: () => selectedPriority.value = priority,
  //     child: Chip(
  //       backgroundColor: isSelected ? color : Colors.grey.shade200,
  //       label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    titleCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}