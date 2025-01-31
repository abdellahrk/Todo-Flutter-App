import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/todo_provider.dart';

import '../model/task.dart';
import '../service/database.dart';

class TaskForm extends StatefulWidget {
  TaskForm({super.key});

  @override
  TaskFormState createState() {
    return TaskFormState();
  }
}

class TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final titlecontroller = TextEditingController();
  final database = MyDatabase();

  @override
  void dispose() {
    descriptionController.dispose();
    titlecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: titlecontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter the description';
                }
                return null;
              },
              decoration: InputDecoration(
                  isDense: true, contentPadding: EdgeInsets.all(40)),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')));
                  }
                  String title = titlecontroller.text.toString();
                  String description = descriptionController.text.toString();
                  var task =
                      Task(title: title, description: description, isDone: 0);
                  context.read<TodoProvider>().addTodo(task);
                },
                child: const Text('Submit'))
          ],
        ));
  }
}
