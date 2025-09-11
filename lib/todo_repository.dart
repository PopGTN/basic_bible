import 'dart:convert';
import 'package:http/http.dart' as http;
import '/TodoModal.dart';

class TodoRepository {
  final String baseUrl = "https://jsonplaceholder.typicode.com/todos";

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  Future<Todo> createTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create todo");
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse("$baseUrl/${todo.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update todo");
    }
  }

  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete todo");
    }
  }
}
