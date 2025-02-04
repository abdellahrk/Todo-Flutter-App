import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/task.dart';

class MyDatabase {
  // _onUpgrade(Database database, int oldVersion, int version) async {
  //   return database.rawQuery();
  // }

  database() async {
    final database = openDatabase(join(await getDatabasesPath(), 'todo.db'),
        onCreate: (Database db, version) {
      return db.execute(
          "CREATE TABLE IF NOT EXISTS tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, isDone INTEGER, remind INTEGER, repeat STRING, color INTEGER, startTime STRING, endTime STRING,createdAt STRING, updatedAt STRING, date STRING, completedAt STRING)");
    }, version: 15);

    return database;
  }

  Future<void> dropDatabase(String name) async {
    final db = await database();
    db.execute("DROP TABLE IF EXISTS $name");
  }

  Future<void> insertTask(Task task) async {
    final db = await database();

    await db.insert('tasks', task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> tasks() async {
    final db = await database();

    final List<Map<String, Object?>> taskMaps = await db.query('tasks');

    return [
      for (final {
            'id': id as int,
            'title': title as String,
            'description': description as String,
            'isDone': isDone as int,
          } in taskMaps)
        Task(id: id, title: title, description: description, isDone: isDone)
    ];
  }

  Future<List<Task>> getDoneTasks() async {
    final db = await database();

    final List<Map<String, Object?>> taskMaps =
        await db.query('tasks', where: '"isDone" = ?', whereArgs: [1]);

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

  Future<List<Task>> getNotDoneTasks() async {
    final db = await database();

    final List<Map<String, Object?>> taskMaps =
        await db.query('tasks', where: '"isDone" = ?', whereArgs: [0]);

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

    var result = await db.query('tasks', where: '"id" = ?', whereArgs: [id]);

    return result;
  }

  Future<void> markDone(int taskId) async {
    final db = await database();

    await db.rawUpdate('UPDATE tasks SET isDone = ? WHERE id = ?', [1, taskId]);
  }

  Future<void> markUnDone(int taskId) async {
    final db = await database();

    await db.rawUpdate('UPDATE tasks SET isDone = ? WHERE id = ?', [0, taskId]);
  }

  Future<void> removeTask(int taskId) async {
    final db = await database();
    await db.rawDelete('DELETE FROM my_tasks WHERE id = ?', [taskId]);
  }
}
