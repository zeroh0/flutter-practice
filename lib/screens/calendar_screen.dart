// 캘린더 화면
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo/models/todo.dart';

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
