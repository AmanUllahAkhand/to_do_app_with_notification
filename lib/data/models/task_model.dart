import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    int? id,
    required String title,
    required String category,
    required DateTime date,
    required String time,
    required String notes,
    bool isCompleted = false,
    bool hasReminder = false,
  }) : super(
    id: id,
    title: title,
    category: category,
    date: date,
    time: time,
    notes: notes,
    isCompleted: isCompleted,
    hasReminder: hasReminder,
  );

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
      hasReminder: map['hasReminder'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'time': time,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'hasReminder': hasReminder ? 1 : 0,
    };
  }
}