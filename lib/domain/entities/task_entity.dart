class TaskEntity {
  final int? id;
  final String title;
  final String category;
  final DateTime date;
  final String time;  // Stored as string for simplicity, e.g., "10:25 PM"
  final String notes;
  final bool isCompleted;
  final bool hasReminder;  // For timeout alerts

  TaskEntity({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.notes,
    this.isCompleted = false,
    this.hasReminder = false,
  });
}