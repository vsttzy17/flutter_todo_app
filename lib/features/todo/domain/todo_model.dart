enum TodoStatus {
  todo,
  inProgress,
  done,
}

class Todo {
  final String id;
  final String title;
  final TodoStatus status;

  Todo({
    required this.id,
    required this.title,
    this.status = TodoStatus.todo,
  });

  Todo copyWith({
    String? id,
    String? title,
    TodoStatus? status,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status.index,
    };
  }

  factory Todo.fromMap(Map map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      status: TodoStatus.values[map['status'] ?? 0],
    );
  }
}
