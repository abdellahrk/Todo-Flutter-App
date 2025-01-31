import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/task.dart';

class MyDatabase {
  _onUpgrade(Database database, int oldVersion, int version) async {
    return database.execute(
      "ALTER TABLE my_tasks ADD updatedAt INTEGER DEFAULT (cast(strftime('%s','now') as int",
      // "ALTER TABLE my_tasks ADD updatedAt INTEGER DEFAULT (cast(strftime('%s','now') as int))"
    );
  }

  database() async {
    final database =
        openDatabase(join(await getDatabasesPath(), 'my_task_db.db'),
            onCreate: (Database db, version) {
      return db.execute(
          "CREATE TABLE IF NOT EXISTS my_tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, isDone INTEGER)");
    }, onUpgrade: _onUpgrade, version: 1);

    return database;
  }

  Future<void> insertTask(Task task) async {
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
            'isDone': isDone as int,
          } in taskMaps)
        Task(id: id, title: title, description: description, isDone: isDone)
    ];
  }

  Future<List<Task>> getDoneTasks() async {
    final db = await database();

    final List<Map<String, Object?>> taskMaps =
        await db.query('my_tasks', where: '"isDone" = ?', whereArgs: [1]);

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
        await db.query('my_tasks', where: '"isDone" = ?', whereArgs: [0]);

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

  Future<void> markDone(int taskId) async {
    final db = await database();

    await db
        .rawUpdate('UPDATE my_tasks SET isDone = ? WHERE id = ?', [1, taskId]);
  }

  Future<void> markUnDone(int taskId) async {
    final db = await database();

    await db
        .rawUpdate('UPDATE my_tasks SET isDone = ? WHERE id = ?', [0, taskId]);
  }

  Future<void> removeTask(int taskId) async {
    final db = await database();
    await db.rawDelete('DELETE FROM my_tasks WHERE id = ?', [taskId]);
  }
}
