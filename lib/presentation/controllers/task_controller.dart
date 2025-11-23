import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/utils/notification_helper.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/local_datasource.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/complete_task.dart';

class TaskController extends GetxController {
  final taskRepo = TaskRepositoryImpl(LocalDataSource.instance);
  var tasks = <TaskEntity>[].obs;
  var completedTasks = <TaskEntity>[].obs;

  late AddTask addTaskUseCase;
  late DeleteTask deleteTaskUseCase;
  late GetTasks getTasksUseCase;
  late UpdateTask updateTaskUseCase;
  late CompleteTask completeTaskUseCase;

  @override
  void onInit() {
    super.onInit();
    addTaskUseCase = AddTask(taskRepo);
    deleteTaskUseCase = DeleteTask(taskRepo);
    getTasksUseCase = GetTasks(taskRepo);
    updateTaskUseCase = UpdateTask(taskRepo);
    completeTaskUseCase = CompleteTask(taskRepo);
    fetchTasks();
    NotificationHelper.initialize();
  }

  Future<void> fetchTasks() async {
    final allTasks = await getTasksUseCase();
    tasks.value = allTasks.where((t) => !t.isCompleted).toList();
    completedTasks.value = allTasks.where((t) => t.isCompleted).toList();
  }

  // Inside TaskController

  Future<void> addNewTask({
    required String title,
    required String category,
    required DateTime date,
    required String time,
    required String notes,
    bool hasReminder = false,
  }) async {
    // Parse time string (e.g., "10:25 PM") into actual DateTime
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final isPM = timeParts.length > 1 && timeParts[1] == 'PM';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final reminderDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    final task = TaskEntity(
      title: title,
      category: category,
      date: date,
      time: time,
      notes: notes,
      hasReminder: hasReminder,
    );

    await addTaskUseCase(task);

    // Schedule reminder only if enabled and time is in future
    if (hasReminder && reminderDateTime.isAfter(DateTime.now())) {
      NotificationHelper.setReminder(
        taskId: DateTime.now().millisecondsSinceEpoch, // temporary ID
        taskTitle: title,
        dateTime: reminderDateTime,
      );
    }

    fetchTasks();
  }

  Future<void> updateExistingTask(TaskEntity task) async {
    await updateTaskUseCase(task);
    fetchTasks();
  }

  Future<void> delete(TaskEntity task) async {
    await deleteTaskUseCase(task.id!);
    fetchTasks();
  }

  Future<void> markComplete(TaskEntity task) async {
    await completeTaskUseCase(task.id!);
    fetchTasks();
  }
}