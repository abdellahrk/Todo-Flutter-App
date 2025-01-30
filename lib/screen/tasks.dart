import 'package:flutter/material.dart';

class Tasks extends StatefulWidget {
  final Map<String, dynamic> data;
  const Tasks({super.key, required this.data});

  @override
  State<Tasks> createState() => _TaskState();
}

class _TaskState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
      ),
    );
  }
}
