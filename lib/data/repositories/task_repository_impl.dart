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
    return models;  // Models extend Entity, so direct return
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    await localDataSource.addTask(TaskModel(
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      notes: task.notes,
      hasReminder: task.hasReminder,
    ));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await localDataSource.updateTask(TaskModel(
      id: task.id,
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      notes: task.notes,
      isCompleted: task.isCompleted,
      hasReminder: task.hasReminder,
    ));
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