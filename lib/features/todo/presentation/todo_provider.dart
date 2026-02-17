import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/todo_local_datasource.dart';
import '../domain/todo_model.dart';

final todoProvider =
    StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]) {
    loadTodos();
  }

  final repo = TodoLocalDataSource();
  final uuid = const Uuid();

  void loadTodos() {
    state = repo.getTodos();
  }

  void addTodo(String title) {
    final todo = Todo(
      id: uuid.v4(),
      title: title,
    );

    repo.addTodo(todo);
    loadTodos();
  }

  void toggleTodo(Todo todo) {
    final updated = todo.copyWith(isDone: !todo.isDone);
    repo.updateTodo(updated);
    loadTodos();
  }

  void deleteTodo(String id) {
    repo.deleteTodo(id);
    loadTodos();
  }
}
