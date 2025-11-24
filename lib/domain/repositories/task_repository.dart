import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks();

  /// ADD TASK AND RETURN THE INSERTED ROW ID
  Future<int> addTask(TaskEntity task);  // ← MUST RETURN int

  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(int id);
  Future<void> completeTask(int id);
}