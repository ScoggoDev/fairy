enum ElementOfTodoType { goal, task }

class ElementOfTodo {
  ElementOfTodo({
    required this.id,
    required this.text,
    required this.elementOfTodoType,
  });

  final int id;
  final String text;
  final ElementOfTodoType elementOfTodoType;
}