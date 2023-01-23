enum ElementOfTodoType { goal, task }

class ElementOfTodo {
  ElementOfTodo({
    required this.text,
    required this.elementOfTodoType,
  });

  final String text;
  final ElementOfTodoType elementOfTodoType;
}