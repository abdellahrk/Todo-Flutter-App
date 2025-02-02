import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/screen/tasks/single.dart';

import '../model/task.dart';
import '../service/database.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final database = MyDatabase();
  int todoCount = TodoProvider().count;

  @override
  void initState() {
    context.read<TodoProvider>().getDoneTaks();
    context.read<TodoProvider>().getNotDoneTaks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<TodoProvider>(
            builder: (BuildContext context, todoProvider, Widget? child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Done (${context.read<TodoProvider>().doneTasks})'),
                    Text(
                        'Not Done(${context.read<TodoProvider>().notDoneTasks})')
                  ],
                ),
            child: null),
        Expanded(
          child: FutureBuilder<List<Task>>(
            future: context.read<TodoProvider>().getTasks(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  var data = snapshot.data;
                  print(snapshot.data);
                  if (snapshot.hasData) {
                    return snapshot.data!.isEmpty
                        ? Text('no data yet')
                        : ListView.builder(
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Dismissible(
                              key: Key(data![index].title),
                              onDismissed: (direction) async {
                                late var id = data[index].id;
                                await context
                                    .read<TodoProvider>()
                                    .deleteTask(id!);
                              },
                              background: Container(
                                color: Colors.redAccent,
                              ),
                              child: Consumer<TodoProvider>(
                                builder: (BuildContext context, todo,
                                        Widget? child) =>
                                    Card(
                                  margin: EdgeInsets.all(10.0),
                                  child: ListTile(
                                    leading: Checkbox(
                                        value: data[index].isDone == 0
                                            ? false
                                            : true,
                                        onChanged: (value) async {
                                          if (value == false) {
                                            context
                                                .read<TodoProvider>()
                                                .markUnDone(
                                                    data[index].id ?? 0);
                                          }

                                          if (value == true) {
                                            context
                                                .read<TodoProvider>()
                                                .markDone(data[index].id ?? 0);
                                          }
                                          setState(() {});
                                        }),
                                    title: Text(snapshot.data![index].title),
                                    subtitle:
                                        Text(snapshot.data![index].description),
                                    onTap: () {
                                      int id = data[index].id ?? 0;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SingleTask(id: id)));
                                    },
                                  ),
                                ),
                                child: null,
                              ),
                            ),
                          );
                  }
                  if (snapshot.hasError) {
                    return Text('There is an error ${snapshot.error}');
                  }
                  return Text('Just here');
                default:
                  return ErrorWidget(Exception('An unexpected error occured'));
              }
            },
          ),
        ),
      ],
    );
  }
}
