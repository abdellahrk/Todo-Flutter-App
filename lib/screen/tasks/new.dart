import 'package:flutter/material.dart';
import 'package:todo/screen/home.dart';
import 'package:todo/widgets/appbar.dart';

import '../../model/task.dart';
import '../../service/database.dart';

class NewTask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewTask();
}

class _NewTask extends State<NewTask> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final database = MyDatabase();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'New Task'),
      body: Container(
        child: Center(
          child: Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
              ),
              TextFormField(
                controller: descriptionController,
              ),
              ElevatedButton(
                  onPressed: () {
                    var snackBar = SnackBar(content: Text('Task Added!'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    String title = titleController.text.toString();
                    String description = descriptionController.text.toString();
                    var task =
                        Task(title: title, description: description, isDone: 1);
                    database.insertTask(task);
                    setState(() {
                      // dataList = dataList;
                    });
                    titleController.clear();
                    descriptionController.clear();
                  },
                  child: Text('Add'))
            ],
          )),
        ),
      ),
    );
  }
}
