import 'package:flutter/material.dart';
import 'package:todo/repository/task_repository.dart';
import 'package:todo/service/database.dart';
import '../../model/task.dart';
import '../../widgets/appbar.dart';

class SingleTask extends StatefulWidget {
  SingleTask({super.key, required this.id});
  final int id;

  @override
  State<SingleTask> createState() => _SingleTaskState();
}

class _SingleTaskState extends State<SingleTask> {
  final database = MyDatabase();

  Future<dynamic> _getTask() async {
    var result = await database.getTask(widget.id);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Task'),
      body: FutureBuilder(
          future: _getTask(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.connectionState == ConnectionState.none) {
              return Text('no data');
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('error');
            }
            var task = Task.fromJson(snapshot.data[0]);

            print(task.id);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge?.fontSize ??
                                30.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(task.description),
                  Text(task.isDone == 0 ? 'False' : 'True'),
                  Text(task!.createdAt!),
                ],
              ),
            );
          }),
    );
  }
}
