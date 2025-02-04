import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/screen/tasks/new.dart';
import 'package:todo/screen/tasks/single.dart';

import '../model/task.dart';
import '../service/database.dart';
import '../service/notification_services.dart';
import '../theme/theme.dart';
import '../ui/widgets/button.dart';
import '../ui/widgets/task_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final database = MyDatabase();
  int todoCount = TodoProvider().count;
  DateTime _selectedDate = DateTime.now();
  List<Task> tasks = [];
  var notifyHelper;
  String? deviceName;
  bool shorted = false;

  double? width;
  double? height;

  @override
  void initState() {
    context.read<TodoProvider>().getDoneTaks();
    context.read<TodoProvider>().getNotDoneTaks();
    _getTask();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    notifyHelper.requestAndroidPermissions();
    super.initState();
  }

  _getTask() async {
    tasks = await context.read<TodoProvider>().getTasks();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        _addTaskBar(),
        _dateBar(),
        const SizedBox(
          height: 10,
        ),
        _showTasks(),
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
                              direction: DismissDirection.horizontal,
                              onDismissed: (direction) async {
                                late var id = data[index].id;
                                await context
                                    .read<TodoProvider>()
                                    .deleteTask(id!);
                              },
                              background: Container(
                                color: Colors.redAccent,
                              ),
                              secondaryBackground: Container(
                                color: Colors.green,
                              ),
                              child: Card(
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
                                              .markUnDone(data[index].id ?? 0);
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

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat("EEE, d MMM yyyy").format(DateTime.now()),
                style: subHeadingStyle.copyWith(fontSize: width! * .049),
              ),
              Text(
                "Today",
                style: headingStyle.copyWith(fontSize: width! * .06),
              )
            ],
          ),
          MyButton(
            label: "+ Add Task",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewTask(
                            task: null,
                          )));
              // _taskController.getTasks();
            },
          )
        ],
      ),
    );
  }

  _dateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10),
      child: DatePicker(
        DateTime.now(),
        height: 125,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryColor,
        selectedTextColor: Colors.white,
        onDateChange: (date) {
          // New date selected
          setState(() {
            _selectedDate = date;
          });
        },
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.039,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.037,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: width! * 0.030,
            fontWeight: FontWeight.normal,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  _showTasks() {
    return Expanded(
      flex: 1,
      child: Consumer<TodoProvider>(
          builder: (BuildContext context, todoProvider, Widget? child) =>
              ListView.builder(
                itemCount: todoCount,
                itemBuilder: (_, index) {
                  Task task = tasks[tasks.length -
                      1 -
                      index]; //filterTaskList[filterTaskList.length - 1 - index];
                  print(task);

                  DateTime date = _parseDateTime(task.createdAt.toString());
                  var myTime = DateFormat.Hm().format(date);

                  var remind = DateFormat.Hm()
                      .format(date.subtract(Duration(minutes: task.remind!)));

                  int mainTaskNotificationId = task.id!.toInt();
                  int reminderNotificationId = mainTaskNotificationId + 1;

                  if (task.repeat == "Daily") {
                    if (task.remind! > 4) {
                      notifyHelper.remindNotification(
                        int.parse(remind.toString().split(":")[0]), //hour
                        int.parse(remind.toString().split(":")[1]), //minute
                        task,
                      );
                      notifyHelper.cancelNotification(reminderNotificationId);
                    }
                    notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(":")[0]), //hour
                      int.parse(myTime.toString().split(":")[1]), //minute
                      task,
                    );
                    notifyHelper.cancelNotification(reminderNotificationId);

                    // update if daily task is completed to reset it every 11:59 pm is not completed
                    if (DateTime.now().hour == 23 &&
                        DateTime.now().minute == 59) {
                      // _taskController.markTaskAsCompleted(task.id!, false);
                    }

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                onLongPress: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                              NewTask(task: null))
                                      // () => AddTaskPage(task: task),
                                      );
                                },
                                child: TaskTile(
                                  task,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (task.createdAt ==
                      DateFormat('MM/dd/yyyy').format(_selectedDate)) {
                    if (task.remind! > 0) {
                      notifyHelper.remindNotification(
                        int.parse(remind.toString().split(":")[0]), //hour
                        int.parse(remind.toString().split(":")[1]), //minute
                        task,
                      );
                      // notifyHelper.cancelNotification(reminderNotificationId);
                    }
                    notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(":")[0]), //hour
                      int.parse(myTime.toString().split(":")[1]), //minute
                      task,
                    );
                    notifyHelper.cancelNotification(reminderNotificationId);

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(
                                  task,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (
                      // task.repeat == "Weekly" &&
                      DateFormat('EEEE').format(_selectedDate) ==
                          DateFormat('EEEE').format(DateTime.now())) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(
                                  task,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (
                      // task.repeat == "Monthly" &&
                      DateFormat('dd').format(_selectedDate) ==
                          DateFormat('dd').format(DateTime.now())) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet(context, task);
                                },
                                child: TaskTile(
                                  task,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )),
    );
  }

  DateTime _parseDateTime(String timeString) {
    // Split the timeString into components (hour, minute, period)
    List<String> components = timeString.split(' ');

    // Extract and parse the hour and minute
    List<String> timeComponents = components[0].split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    // If the time string contains a period (AM or PM),
    //adjust the hour for 12-hour format
    if (components.length > 1) {
      String period = components[1];
      if (period.toLowerCase() == 'pm' && hour < 12) {
        hour += 12;
      } else if (period.toLowerCase() == 'am' && hour == 12) {
        hour = 0;
      }
    }

    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute);
  }

  void _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isDone == 1
            ? MediaQuery.of(context).size.height * 0.28
            : MediaQuery.of(context).size.height * 0.35,
        color: Get.isDarkMode ? darkGreyColor : Colors.white,
        child: Column(children: [
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
            ),
          ),
          const Spacer(),
          _bottomSheetButton(
            label: " Update Task",
            color: Colors.green[400]!,
            onTap: () {
              Get.back();
              // Get.to(() => AddTaskPage(task: task));
            },
            context: context,
            icon: Icons.update,
          ),
          task.isDone == 1
              ? Container()
              : _bottomSheetButton(
                  label: "Task Completed",
                  color: primaryColor,
                  onTap: () {
                    // Get.back();
                    // _taskController.markTaskAsCompleted(task.id!, true);
                    // _taskController.getTasks();
                  },
                  context: context,
                  icon: Icons.check,
                ),
          _bottomSheetButton(
            label: "Delete Task",
            color: Colors.red[400]!,
            onTap: () {
              Get.back();
              showDialog(
                  context: context,
                  builder: (_) => _alertDialogBox(context, task));
              // _taskController.deleteTask(task.id!);
            },
            context: context,
            icon: Icons.delete,
          ),
          const SizedBox(height: 15),
          _bottomSheetButton(
            label: "Close",
            color: Colors.red[400]!.withOpacity(0.5),
            isClose: true,
            onTap: () {
              Get.back();
            },
            context: context,
            icon: Icons.close,
          ),
        ]),
      ),
    );
  }

  _bottomSheetButton(
      {required String label,
      required BuildContext context,
      required Color color,
      required Function()? onTap,
      IconData? icon,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 7),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,

        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose
                ? Get.isDarkMode
                    ? Colors.grey[700]!
                    : Colors.grey[300]!
                : color,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : color,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: isClose
                        ? Get.isDarkMode
                            ? Colors.white
                            : Colors.black
                        : Colors.white,
                    size: 30,
                  )
                : const SizedBox(),
            Text(
              label,
              style: titleStyle.copyWith(
                fontSize: 18,
                color: isClose
                    ? Get.isDarkMode
                        ? Colors.white
                        : Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _alertDialogBox(BuildContext context, Task task) {
    return AlertDialog(
      backgroundColor: context.theme.colorScheme.background,
      icon: const Icon(Icons.warning, color: Colors.red),
      title: const Text("Are you sure you want to delete?"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Get.back();
              // _taskController.deleteTask(task.id!);
              // Cancel delete notification
              // if (task.remind! > 4) {
              //   notifyHelper.cancelNotification(task.id! + 1);
              // }
              _showTasks();
            },
            child: const SizedBox(
              width: 60,
              child: Text(
                "Yes",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Get.back();
            },
            child: const SizedBox(
              width: 60,
              child: Text(
                "No",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
