import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'TodoModal.dart';
import './todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, AsyncValue<List<Todo>>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return TodoListNotifier(repo);
});

class TodoListNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoRepository repository;

  TodoListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      final todos = await repository.fetchTodos();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await repository.createTodo(todo);
      state = AsyncValue.data([...state.value ?? [], newTodo]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final updated = await repository.updateTodo(todo);
      state = AsyncValue.data([
        for (final t in state.value ?? [])
          if (t.id == todo.id) updated else t
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
      state = AsyncValue.data([
        for (final t in state.value ?? [])
          if (t.id != id) t
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
