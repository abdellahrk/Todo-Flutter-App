import 'package:flutter/material.dart';
import 'package:todo/screen/home.dart';
import 'package:todo/widgets/appbar.dart';
import 'package:todo/widgets/task_form.dart';

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
  final _formKey = GlobalKey<FormState>();

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
        child: Center(child: TaskForm()),
      ),
    );
  }
}
