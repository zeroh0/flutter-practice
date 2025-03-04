import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할 일 목록',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 표시될 화면 목록
  final List<Widget> _screens = [
    const TodayTodoScreen(),
    const CalendarScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('할 일 목록')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: '오늘 할 일'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// 오늘 할 일 화면
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

// 캘린더 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Todo>> _events = {};
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  // 선택한 날짜의 이벤트 목록을 가져오는 함수
  List<Todo> _getEventsForDay(DateTime day) {
    // Convert DateTime to yyyy-MM-dd format for proper comparison
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  // 새 할 일 추가 함수
  void _addNewTask() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('할 일 추가'),
            content: TextField(
              controller: _eventController,
              decoration: const InputDecoration(hintText: '할 일을 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_eventController.text.isEmpty) return;

                  setState(() {
                    // Convert DateTime to yyyy-MM-dd format for proper storage
                    final normalizedDate = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    );

                    // 해당 날짜에 이벤트가 없으면 빈 리스트 생성
                    if (_events[normalizedDate] == null) {
                      _events[normalizedDate] = [];
                    }

                    // 새 할 일 추가
                    _events[normalizedDate]!.add(
                      Todo(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _eventController.text,
                        completed: false,
                      ),
                    );

                    _eventController.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  // 할 일 완료/미완료 토글 함수
  void _toggleTask(Todo task) {
    setState(() {
      final normalizedDate = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      final taskIndex = _events[normalizedDate]!.indexWhere(
        (t) => t.id == task.id,
      );
      if (taskIndex != -1) {
        _events[normalizedDate]![taskIndex] =
            _events[normalizedDate]![taskIndex].copyWith(
              completed: !_events[normalizedDate]![taskIndex].completed,
            );
      }
    });
  }

  // 할 일 삭제 함수
  void _deleteTask(Todo task) {
    setState(() {
      final normalizedDate = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      _events[normalizedDate]!.removeWhere((t) => t.id == task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: _addNewTask,
                icon: const Icon(Icons.add),
                label: const Text('할 일 추가'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child:
              _selectedDay == null
                  ? const Center(child: Text('날짜를 선택하세요'))
                  : _getEventsForDay(_selectedDay!).isEmpty
                  ? const Center(child: Text('선택한 날짜의 할 일이 없습니다'))
                  : ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay!)[index];
                      return ListTile(
                        leading: Checkbox(
                          value: event.completed,
                          onChanged: (value) {
                            _toggleTask(event);
                          },
                        ),
                        title: Text(
                          event.title,
                          style: TextStyle(
                            decoration:
                                event.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(event),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

// 할 일 모델 클래스
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, required this.completed});

  Todo copyWith({String? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
