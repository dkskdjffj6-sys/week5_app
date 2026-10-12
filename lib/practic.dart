import 'package:flutter/material.dart';

void main() {
  runApp(const CleanTodoApp());
}

// ==========================================
// 1. Model (단일 책임 원칙 - 데이터 구조)
// ==========================================
class TodoItem {
  final String id;
  String title; // 수정이 가능해야 하므로 final 제거
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  void toggle() {
    isCompleted = !isCompleted;
  }
}

// ==========================================
// 2. ViewModel / State (CRUD 상태 관리 로직)
// ==========================================
class TodoController extends ChangeNotifier {
  final List<TodoItem> _todos = [
    TodoItem(id: '1', title: '5주차 강의 복습'),
    TodoItem(id: '2', title: '상태 흐름도 작성'),
    TodoItem(id: '3', title: '운영체제 기출문제 3회독'),
  ];

  List<TodoItem> get todos => _todos;
  int get remainingCount => _todos.where((todo) => !todo.isCompleted).length;

  // C: 새 할 일 추가 (SNS 피드처럼 가장 위에 추가)
  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
      title: title,
    );
    _todos.insert(0, newItem);
    notifyListeners();
  }

  // U: 할 일 내용 수정
  void updateTodo(String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].title = newTitle;
      notifyListeners();
    }
  }

  // D: 할 일 삭제
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  // 완료 상태 토글
  void toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].toggle();
      notifyListeners();
    }
  }
}

// ==========================================
// 3. View (메인 화면 및 다이얼로그)
// ==========================================
class CleanTodoApp extends StatelessWidget {
  const CleanTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007A5E)),
      ),
      home: const TodoFeedScreen(),
    );
  }
}

class TodoFeedScreen extends StatefulWidget {
  const TodoFeedScreen({super.key});

  @override
  State<TodoFeedScreen> createState() => _TodoFeedScreenState();
}

class _TodoFeedScreenState extends State<TodoFeedScreen> {
  final TodoController _controller = TodoController();

  @override
  void initState() {
    super.initState();
    // 상태가 변할 때마다 화면을 다시 그리도록 연결
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 글쓰기 & 수정 다이얼로그 재사용 함수 (DRY 원칙)
  void _showTodoDialog({String? id, String? currentTitle}) {
    final textController = TextEditingController(text: currentTitle);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? '할 일 수정' : '새 할 일 작성'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: '무엇을 해야 하나요?'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (isEditing) {
                _controller.updateTodo(id, textController.text);
              } else {
                _controller.addTodo(textController.text);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? '수정완료' : '게시'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 할 일', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
            child: Text(
              '남은 할 일 ${_controller.remainingCount}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF007A5E)),
            ),
          ),
          ..._controller.todos.map((todo) => SnsStyleTodoCard(
            todo: todo,
            onToggle: () => _controller.toggleTodo(todo.id),
            onEdit: () => _showTodoDialog(id: todo.id, currentTitle: todo.title),
            onDelete: () => _controller.deleteTodo(todo.id),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoDialog(),
        icon: const Icon(Icons.edit),
        label: const Text('글쓰기'),
      ),
    );
  }
}

// ==========================================
// 4. 재사용 가능한 UI 컴포넌트 (팝업 메뉴 추가됨)
// ==========================================
class SnsStyleTodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SnsStyleTodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF007A5E),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('컴공과 2학년', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('방금 전 • 남은 기한 14일'),
            // 수정된 부분: PopupMenuButton으로 수정/삭제 옵션 제공
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz), //[cite: 3] 사진의 더보기 아이콘 기능 구현
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('수정하기')),
                const PopupMenuItem(value: 'delete', child: Text('삭제하기', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: todo.isCompleted ? const Color(0xFF007A5E) : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    todo.isCompleted ? '완료 취소' : '완료하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: todo.isCompleted ? const Color(0xFF007A5E) : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}