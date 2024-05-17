import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/todo_model.dart';
import 'add_todo_page.dart';

enum TodoFilter {
  All,
  Today,
  Upcoming,
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({Key? key}) : super(key: key);

  @override
  TodoHomePageState createState() => TodoHomePageState();
}

class TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController searchController = TextEditingController();
  late List<Todo> todos; // List to store todos
  late List<Todo> filteredTodos; // List to filter todos
  late TodoFilter currentFilter; // Current filter option
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    todos = generateSampleTodos();
    filteredTodos = todos;
    currentFilter = TodoFilter.All;

    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO App'),
      ),
      body: Column(
        children: [
          buildFilterOptions(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search for todos...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterTodos,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                final isOverdue = todo.isOverdue();
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text(
                    todo.time.toString(),
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text(
                                'Confirm success',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              content: const Text(
                                'Have you definitely completed this task?',
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text(
                                        'Cancel',
                                      ),
                                    ),
                                    const SizedBox(width: 16), // Add spacing between the buttons
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          todos.remove(filteredTodos[index]);
                                          filteredTodos = todos;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                        'Yes',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddTodoPage(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildFilterButton('All', TodoFilter.All),
        buildFilterButton('Today', TodoFilter.Today),
        buildFilterButton('Upcoming', TodoFilter.Upcoming),
      ],
    );
  }

  Widget buildFilterButton(String text, TodoFilter filter) {
    return TextButton(
      onPressed: () {
        setState(() {
          currentFilter = filter;
          filterTodos(searchController.text);
        });
      },
      child: Text(text, style: TextStyle(
        color: currentFilter == filter ? Colors.purple.shade300 : Colors.black,
      )),
    );
  }

  void filterTodos(String value) {
    setState(() {
      filteredTodos = todos.where((todo) {
        if (value.isNotEmpty &&
            !todo.title.toLowerCase().contains(value.toLowerCase())) {
          return false;
        }
        if (currentFilter == TodoFilter.Today) {
          return todo.time.isToday();
        } else if (currentFilter == TodoFilter.Upcoming) {
          return todo.time.isAfter(DateTime.now());
        }
        return true;
      }).toList();
    });
  }

  void navigateToAddTodoPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoPage()),
    );
    if (result != null && result is Todo) {
      setState(() {
        todos.add(result);
        filteredTodos = todos;
      });
      scheduleNotification(result);
    }
  }

  void scheduleNotification(Todo todo) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'todo_notification_channel',
      'TODO Notifications',
      'Channel for TODO notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      todo.id.hashCode,
      'Reminder for ${todo.title}',
      'Your TODO "${todo.title}" is due now!',
      todo.time.subtract(const Duration(minutes: 10)),
      platformChannelSpecifics,
    );
  }

  List<Todo> generateSampleTodos() {
    return [
      Todo(
        id: 1,
        title: 'Deadline',
        time: DateTime(2024, 01, 29, 09, 00),
      ),
      Todo(
        id: 2,
        title: 'Write report',
        time: DateTime(2024, 01, 30, 09, 00),
      ),
      Todo(
        id: 3,
        title: 'Seminar',
        time: DateTime(2024, 01, 31, 09, 00),
      ),
    ];
  }
}

extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension TodoExtensions on Todo {
  bool isOverdue() {
    return time.isBefore(DateTime.now());
  }
}