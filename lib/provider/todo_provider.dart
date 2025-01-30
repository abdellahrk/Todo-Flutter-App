import 'package:flutter/foundation.dart';
import 'package:todo/repository/task_repository.dart';
import 'package:todo/service/database.dart';

import '../model/task.dart';

class TodoProvider extends ChangeNotifier {
  int _count = 0;
  int _doneTasks = 0;
  int _notDoneTasks = 0;
  final repository = TaskRepository();
  final database = MyDatabase();

  void markDone(int taskId) async {
    await database.markDone(taskId);
    getDoneTaks();
    getNotDoneTaks();
  }

  void markUnDone(int taskId) async {
    await database.markUnDone(taskId);
    getDoneTaks();
    getNotDoneTaks();
    notifyListeners();
  }

  Future<List<Task>> getTasks() async {
    return await database.tasks();
  }

  int get count => _count;
  int get doneTasks => _doneTasks;
  int get notDoneTasks => _notDoneTasks;

  void getDoneTaks() async {
    var res = await database.getDoneTasks();
    _doneTasks = res.length;
    notifyListeners();
  }

  void getNotDoneTaks() async {
    var res = await database.getNotDoneTasks();
    _notDoneTasks = res.length;
    notifyListeners();
  }

  void incrementCount() {
    _count++;
    notifyListeners();
  }
}
