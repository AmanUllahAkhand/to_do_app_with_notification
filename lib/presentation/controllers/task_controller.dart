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

  // lib/presentation/controllers/task_controller.dart

  Future<int> addNewTask({
    required String title,
    required String category,
    required DateTime date,
    required String time,
    required String notes,
    bool hasReminder = false,
    // TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = TaskEntity(
      title: title,
      category: category,
      date: date,
      time: time,
      notes: notes,
      hasReminder: hasReminder,
      // priority: priority,
    );

    // Now this works — returns real int ID
    final int insertedId = await addTaskUseCase(task);

    await fetchTasks(); // Refresh UI
    return insertedId;  // Used for scheduling notification
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
  // In TaskController

  Future<void> unmarkComplete(TaskEntity task) async {
    final updatedTask = TaskEntity(
      id: task.id,
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      notes: task.notes,
      isCompleted: false, // ← Set back to false
      hasReminder: task.hasReminder,
    );
    await updateTaskUseCase(updatedTask);
    fetchTasks(); // Refresh the lists
  }
}