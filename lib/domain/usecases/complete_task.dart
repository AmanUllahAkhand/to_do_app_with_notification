import '../repositories/task_repository.dart';

class CompleteTask {
  final TaskRepository repository;

  CompleteTask(this.repository);

  Future<void> call(int id) {
    return repository.completeTask(id);
  }
}