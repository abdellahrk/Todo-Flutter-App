import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/todo_provider.dart';
import 'package:todo/screen/home.dart';
import 'package:todo/screen/tasks/all.dart';
import 'package:todo/screen/tasks/new.dart';
import 'package:todo/service/database.dart';
import 'package:path/path.dart';

import 'device_info.dart';
import 'model/task.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => TodoProvider())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Todo App'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> tasks = [];
  int _currentPageIndex = 0;
  DeviceInfo deviceInfo = DeviceInfo();
  String? deviceName;

  final _pages = [
    Home(),
    AllTasks(),
    NewTask(
      task: null,
    )
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DeviceInfo deviceInfo = DeviceInfo();
    deviceInfo.getDeviceName().then((value) {
      setState(() {
        deviceName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TodoProvider>().incrementCount();
        },
        child: Icon(Icons.plus_one),
      ),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          InputChip(
            padding: const EdgeInsets.all(0),
            label: Text(
              deviceName ?? "Unknown",
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            onPressed: () {},
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              setState(() {
                // Sort the taskList when the sort button is pressed
                // filterTaskList = _shortNotesByModifiedDate(filterTaskList);
              });
            },
            icon: Container(
              // padding: const EdgeInsets.all(10),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode
                    ? Colors.grey.shade800.withOpacity(.8)
                    : Colors.grey[300],
              ),
              // child: Icon(
              //   // shorted ? Icons.filter_alt : Icons.filter_alt_off_sharp,
              //   size: 26,
              //   color: Get.isDarkMode ? Colors.white : Colors.black,
              // ),
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 25),
            // color: Get.isDarkMode ? darkGreyColor : Colors.white,
            icon: const Icon(Icons.more_vert),
            padding: const EdgeInsets.symmetric(horizontal: 0),
            tooltip: "More",
            onSelected: (value) async {
              if (value == "Export to CSV") {
                // Export the taskList to CSV
                // await exportTasksToCSV(filterTaskList);
              } else if (value == "Export to Excel") {
                // Export the taskList to Excel
                // await exportTasksToExcel(filterTaskList);
              } else if (value == "Save as PDF") {
                // Export the taskList to PDF
                // await exportTasksToPDF(filterTaskList);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "Export to CSV",
                  child: Text("Export to CSV"),
                ),
                const PopupMenuItem(
                  value: "Export to Excel",
                  child: Text("Export to Excel"),
                ),
                const PopupMenuItem(
                  value: "Save as PDF",
                  child: Text("Save as PDF"),
                ),
              ];
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          print(index);
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
            selectedIcon: Icon(Icons.home_outlined),
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'List',
            selectedIcon: Icon(Icons.list_outlined),
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'New',
            selectedIcon: Icon(Icons.add_outlined),
          )
        ],
        selectedIndex: _currentPageIndex,
        indicatorColor: Colors.amber,
      ),
      body: _pages[_currentPageIndex],
    );
  }
}
