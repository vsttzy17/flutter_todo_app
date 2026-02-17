import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/todo/presentation/todo_provider.dart';
import 'features/todo/domain/todo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('todos');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final Todo todo = todos[index];

          return ListTile(
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (_) {
                ref.read(todoProvider.notifier).toggleTodo(todo);
              },
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration:
                    todo.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(todoProvider.notifier).deleteTodo(todo.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan todo...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(todoProvider.notifier)
                    .addTodo(controller.text);

                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
