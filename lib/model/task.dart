class Task {
  int? id;
  late String title;
  late String description;
  late int isDone;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.isDone});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
    };
  }

  Task.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    isDone = map['isDone'];
  }

  @override
  String toString() {
    return 'Task: {$title, $description, $isDone} ';
  }
}
