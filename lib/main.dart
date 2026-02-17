import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/todo/presentation/todo_provider.dart';
import 'features/todo/domain/todo_model.dart';

import 'package:google_fonts/google_fonts.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  bool isSearching = false;
  final searchController = TextEditingController();

  void _confirmDelete(BuildContext context, WidgetRef ref, Todo todo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Todo'),
        content: const Text('Yakin mau hapus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(todoProvider.notifier).deleteTodo(todo.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final keyword = ref.watch(searchProvider).toLowerCase();
    final filteredTodos = todos.where((todo) {
      return todo.title.toLowerCase().contains(keyword);
    }).toList();

    final todoList = filteredTodos.where((e) => e.status == TodoStatus.todo).toList();
    final progressList = filteredTodos.where((e) => e.status == TodoStatus.inProgress).toList();
    final doneList = filteredTodos.where((e) => e.status == TodoStatus.done).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 0,
        centerTitle: true,

        leading: const Icon(
          Icons.task_alt,
          color: Colors.white,
        ),

        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari todo...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white70,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(searchProvider.notifier).state = value;
                },
              )
            : Text(
                'My Todo',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  ref.read(searchProvider.notifier).state = '';
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),



      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          buildSection('To Do', todoList, ref, context, Colors.grey, Icons.list_alt, (todo) => _confirmDelete(context, ref, todo),),
          buildSection('In Progress', progressList, ref, context, Colors.blue, Icons.autorenew, (todo) => _confirmDelete(context, ref, todo),),
          buildSection('Done', doneList, ref, context, Colors.green, Icons.check_circle, (todo) => _confirmDelete(context, ref, todo),),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
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

              ScaffoldMessenger.of(context)
                ..clearSnackBars() // hapus antrian lama biar ga delay
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Todo berhasil ditambahkan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );

            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

}

Widget buildSection(
  String title,
  List<Todo> items,
  WidgetRef ref,
  BuildContext context,
  Color color,
  IconData icon,
  Function(Todo) onDelete,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,

        title: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                items.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: 'Clear section',
              onPressed: items.isEmpty
                  ? null
                  : () => _confirmClearSection(context, ref, items),
            ),
          ],
        ),

        children: [

          if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada todo di $title',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,

                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;

                  ref
                      .read(todoProvider.notifier)
                      .reorderTodo(oldIndex, newIndex);
                },

                children: List.generate(items.length, (index) {
                  final todo = items[index];

                  return Card(
                    key: ValueKey(todo.id),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_indicator,
                          color: Colors.grey,
                        ),
                      ),

                      title: Text(todo.title),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<TodoStatus>(
                            onSelected: (value) {
                              ref
                                  .read(todoProvider.notifier)
                                  .updateStatus(todo, value);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: TodoStatus.todo,
                                child: Text('To Do'),
                              ),
                              PopupMenuItem(
                                value: TodoStatus.inProgress,
                                child: Text('In Progress'),
                              ),
                              PopupMenuItem(
                                value: TodoStatus.done,
                                child: Text('Done'),
                              ),
                            ],
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () =>
                                _showEditDialog(context, ref, todo),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => onDelete(todo),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

void _showEditDialog(
  BuildContext context,
  WidgetRef ref,
  Todo todo,
) {
  final controller = TextEditingController(text: todo.title);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit Todo'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Ubah todo...',
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
                  .updateTitle(todo, controller.text);

              Navigator.pop(context);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

void _confirmClearSection(
  BuildContext context,
  WidgetRef ref,
  List<Todo> items,
) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Hapus Semua'),
      content: Text(
        'Hapus ${items.length} todo di section ini?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            for (var todo in items) {
              ref
                  .read(todoProvider.notifier)
                  .deleteTodo(todo.id);
            }
            Navigator.pop(context);
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}
