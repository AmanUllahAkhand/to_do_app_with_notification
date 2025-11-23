import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}