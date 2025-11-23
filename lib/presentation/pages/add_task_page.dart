// lib/presentation/pages/add_task_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  late Rx<TimeOfDay> selectedTimeOfDay; // ← Use TimeOfDay instead of String
  late RxBool hasReminder;

  final TaskController ctrl = Get.find();

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    notesCtrl = TextEditingController(text: widget.task?.notes ?? '');

    selectedCategory = (widget.task?.category ?? 'home').obs;
    selectedDate = (widget.task?.date ?? DateTime.now()).obs;

    // Safely parse saved time string → TimeOfDay
    final savedTimeStr = widget.task?.time ?? '10:00 AM';
    selectedTimeOfDay = _parseTimeString(savedTimeStr).obs;

    hasReminder = (widget.task?.hasReminder ?? false).obs;
  }

  // Helper: Convert "10:25 PM" or "22:25" → TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final format = timeStr.contains('AM') || timeStr.contains('PM')
          ? DateFormat('h:mm a')
          : DateFormat('HH:mm');
      final dateTime = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (e) {
      return const TimeOfDay(hour: 10, minute: 0); // fallback
    }
  }

  // Convert TimeOfDay → "10:25 PM"
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

              // Time Picker – NOW 100% WORKING
              Obx(() => ListTile(
                title: Text('Time: ${_formatTime(selectedTimeOfDay.value)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTimeOfDay.value,
                  );
                  if (time != null) {
                    selectedTimeOfDay.value = time;
                  }
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
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Title is required', backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  final timeString = _formatTime(selectedTimeOfDay.value);

                  if (widget.task == null) {
                    // Add new
                    ctrl.addNewTask(
                      title: titleCtrl.text.trim(),
                      category: selectedCategory.value,
                      date: selectedDate.value,
                      time: timeString,
                      notes: notesCtrl.text,
                      hasReminder: hasReminder.value,
                    );
                  } else {
                    // Update existing
                    final updatedTask = TaskEntity(
                      id: widget.task!.id,
                      title: titleCtrl.text.trim(),
                      category: selectedCategory.value,
                      date: selectedDate.value,
                      time: timeString,
                      notes: notesCtrl.text,
                      isCompleted: widget.task!.isCompleted,
                      hasReminder: hasReminder.value,
                    );
                    ctrl.updateExistingTask(updatedTask);
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

  @override
  void dispose() {
    titleCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}