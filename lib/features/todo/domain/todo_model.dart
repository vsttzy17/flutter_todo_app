class Todo {
  final String id;
  final String title;
  final bool isDone;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory Todo.fromMap(Map map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'],
    );
  }
}
