import 'package:hive/hive.dart';
import '../domain/todo_model.dart';

class TodoLocalDataSource {
  final box = Hive.box('todos');

  List<Todo> getTodos() {
    final data = box.values.toList();

    return data
        .map((e) => Todo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  void addTodo(Todo todo) {
    box.put(todo.id, todo.toMap());
  }

  void deleteTodo(String id) {
    box.delete(id);
  }

  void updateTodo(Todo todo) {
    box.put(todo.id, todo.toMap());
  }
}
