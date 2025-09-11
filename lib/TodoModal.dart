class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
  });

  // From API (JSON → Dart)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      title: json['title'],
      completed: json['completed'] ?? false,
    );
  }

  // To API (Dart → JSON)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "completed": completed,
    };
  }

  Todo copyWith({String? title, bool? completed}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
