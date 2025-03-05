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
