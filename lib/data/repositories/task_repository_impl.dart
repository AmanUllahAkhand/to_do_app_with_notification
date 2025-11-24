import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<List<TaskEntity>> getTasks() async {
    final models = await localDataSource.getTasks();
    return models.map((model) => model as TaskEntity).toList();
  }

  @override
// lib/data/repositories/task_repository_impl.dart

  @override
  Future<int> addTask(TaskEntity task) async {
    final model = TaskModel(
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      notes: task.notes,
      isCompleted: task.isCompleted,
      hasReminder: task.hasReminder,
      // priority: task.priority,
    );

    // This returns the inserted row ID from SQLite
    return await localDataSource.addTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      notes: task.notes,
      isCompleted: task.isCompleted,
      hasReminder: task.hasReminder,
      // priority: task.priority,
    );

    await localDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(int id) async {
    await localDataSource.deleteTask(id);
  }

  @override
  Future<void> completeTask(int id) async {
    await localDataSource.completeTask(id);
  }
}