import 'package:sqflite/sqflite.dart';
import 'package:todo/model/task.dart';
import 'package:todo/service/database.dart';

class TaskRepository {
  final database = MyDatabase.database();

  void addTask(Task task) async {
    final db = await database();

    await db.insert('my_tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> tasks() async {
    final db = await database();

    final List<Map<String, Object?>> taskMaps = await db.query('my_tasks');

    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'description': description as String,
            'isDone': isDone as int
          } in taskMaps)
        Task(id: id, title: title, description: description, isDone: isDone)
    ];
  }

  Future<dynamic> getTask(int id) async {
    final db = await database();

    var result = await db.query('my_tasks', where: '"id" = ?', whereArgs: [id]);

    return result;
  }
}
