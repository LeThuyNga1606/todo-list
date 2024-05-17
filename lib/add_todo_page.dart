import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/todo_model.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  AddTodoPageState createState() => AddTodoPageState();
}

class AddTodoPageState extends State<AddTodoPage> {
  late TextEditingController titleController;
  late DateTime selectedDateTime; // Selected date and time

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    selectedDateTime = DateTime.now(); // Default date and time is now
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add TODO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Choose time: ',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        selectDateTime(context);
                      },
                      icon: const Icon(Icons.event),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Date and Time: ',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    addTodo();
                  },
                  child: const Text('Add Todo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(3600),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void addTodo() {
    final title = titleController.text.trim();
    if (title.isNotEmpty) {
      Navigator.pop(
        context,
        Todo(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          time: selectedDateTime,
        ),
      );
    } else {
      showErrorDialog('Please enter a title');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fail', textAlign: TextAlign.center,),
        content: Text(message, textAlign: TextAlign.center,),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
