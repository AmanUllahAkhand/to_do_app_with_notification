// lib/domain/usecases/add_task.dart

import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  /// Returns the inserted task's database ID
  Future<int> call(TaskEntity task) async {
    return await repository.addTask(task);
  }
}