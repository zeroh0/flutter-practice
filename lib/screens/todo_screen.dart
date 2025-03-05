import 'package:flutter/material.dart';
import 'package:todo/models/todo.dart';

class TodayTodoScreen extends StatefulWidget {
  const TodayTodoScreen({Key? key}) : super(key: key);

  @override
  _TodayTodoScreenState createState() => _TodayTodoScreenState();
}

class _TodayTodoScreenState extends State<TodayTodoScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodo(String title) {
    setState(() {
      _todos.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          completed: false,
        ),
      );
      _textController.clear();
    });
  }

  void _toggleTodo(String id, bool isCompleted) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex] = _todos[todoIndex].copyWith(completed: isCompleted);
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: '할 일을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addTodo(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    _addTodo(_textController.text);
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _todos.isEmpty
                  ? const Center(child: Text('등록된 할 일이 없습니다.'))
                  : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.completed,
                          onChanged: (value) {
                            _toggleTodo(todo.id, value ?? false);
                          },
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration:
                                todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteTodo(todo.id);
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
