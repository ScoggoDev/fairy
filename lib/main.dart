import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api/model.dart';

void main() {
  print("HOLA");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundColor = Color(0xff343541);
const taskBackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future<String> generateResponse(String prompt) async {
  print("object");
  const apiKey = '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';

  var url = Uri.https("api.openai.com", "/v1/completions");
  print(url);
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);
  print("RESPONSE " + newresponse['choices'][0]['text']);
  print("RESPONSE " + response.body);
  return newresponse['choices'][0]['text'];
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ElementOfTodo> _messages = [];
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            ),
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: taskBackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
          onPressed: () async {
            setState(
              () {
                _messages.add(
                  ElementOfTodo(
                    text: _textController.text,
                    elementOfTodoType: ElementOfTodoType.goal,
                  ),
                );
                isLoading = true;
              },
            );
            var input = 'I want to ' + _textController.text + ' divide this goal into smaller steps and return it in a todo list format.';
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                _messages.add(
                  ElementOfTodo(
                    text: value,
                    elementOfTodoType: ElementOfTodoType.task,
                  ),
                );
              });
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
          },
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: taskBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        if(message.elementOfTodoType == ElementOfTodoType.goal) {
            return TodoElementsWidget(
              text: message.text,
              elementOfTodoType: message.elementOfTodoType,
              onChanged: (bool value) {

              },
            );
          } else {
            // Split the input string into lines
            List<String> lines = message.text.split("\n");

            // Initialize an empty list to hold the tasks
            List<String> tasks = [];

            // Iterate through the lines and add the tasks to the list
            final taskRegExp = RegExp(r'^[0-9]\.');
            for (String line in lines) {
              if (taskRegExp.hasMatch(line)) {
                tasks.add(line);
              }
            }
            return GoalElementsWidget(
              text: message.text,
              elementOfTodoType: message.elementOfTodoType,
              tasks: tasks,
            );
          }
        }
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

// ignore: must_be_immutable
class GoalElementsWidget extends StatelessWidget {
  GoalElementsWidget({key, required this.text, required this.tasks, required this.elementOfTodoType});

  final elementOfTodoType;
  final String text;
  final List<String> tasks;
  var _checked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      color: taskBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: tasks.map((task) => TodoElementsWidget(text: task, elementOfTodoType: elementOfTodoType, onChanged: _updateCheckbox)).toList(),
                    ),
                  )

                ],
              ),
            ),
        ],
      ),
    );
  }
  void _updateCheckbox(bool value) {
    //update _checked variable here depending on the value of all tasks
  }
}

// ignore: must_be_immutable
class TodoElementsWidget extends StatefulWidget {
  TodoElementsWidget({key, required this.text, required this.onChanged, required this.elementOfTodoType});
  
  final elementOfTodoType;
  final String text;
  final Function onChanged;

  @override
  _TodoElementsWidgetState createState() => _TodoElementsWidgetState(text: text, elementOfTodoType: elementOfTodoType);
}


class _TodoElementsWidgetState extends State<TodoElementsWidget> {

  _TodoElementsWidgetState({required this.text, required this.elementOfTodoType});  
  var _isCompleted = false;
  var elementOfTodoType;
  String text;

  @override
  Widget build(BuildContext context) {
    bool isGoal = elementOfTodoType == ElementOfTodoType.goal;
    return Container(
      margin: isGoal ? const EdgeInsets.symmetric(vertical: 0.0) : const EdgeInsets.only(left: 40.0),
      color: isGoal ? backgroundColor : taskBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
            Container(
                  margin: const EdgeInsets.only(right: 16.0, left: 0),
                  child: Checkbox(
                    value: _isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCompleted = !_isCompleted;
                        widget.onChanged(_isCompleted);
                      });
                    },
                )
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
                    decoration: _isCompleted 
                      ? BoxDecoration(
                          border: Border(
                          bottom: BorderSide(
                          color: Colors.black,
                            width: 1.0,
                            style: BorderStyle.solid)),
                      )
                  : null,
                    child: 
                      Row(children: [
                        _isCompleted ? 
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.white,
                              ),
                            ),
                          ):
                          Expanded(child: Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),),
                      ],
                    )  
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void deleteOnPressed() {
  }
}
