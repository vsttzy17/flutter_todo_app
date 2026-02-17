import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/todo_model.dart';
import '../data/todo_local_datasource.dart';

final todoProvider =
    StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

final searchProvider = StateProvider<String>((ref) => '');

class TodoNotifier extends StateNotifier<List<Todo>> {
  final TodoLocalDataSource _dataSource = TodoLocalDataSource();

  TodoNotifier() : super([]) {
    loadTodos();
  }

  void loadTodos() {
    state = _dataSource.getTodos();
  }

  void addTodo(String title) {
    final todo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );

    _dataSource.addTodo(todo);
    loadTodos();
  }

  void updateTitle(Todo todo, String newTitle) {
    final updated = todo.copyWith(title: newTitle);

    _dataSource.updateTodo(updated);

    state = [
      for (final t in state)
        if (t.id == todo.id) updated else t
    ];
  }

  void deleteTodo(String id) {
    _dataSource.deleteTodo(id);
    loadTodos();
  }

  void updateStatus(Todo todo, TodoStatus status) {
    final updated = todo.copyWith(status: status);
    _dataSource.updateTodo(updated);
    loadTodos();
  }

  void reorderTodo(int oldIndex, int newIndex) {
    final list = [...state];

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    state = list;
  }


}

