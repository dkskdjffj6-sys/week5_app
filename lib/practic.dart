import 'package:flutter/material.dart';

void main() {
  runApp(const CleanTodoApp());
}

// ==========================================
// 1. Model (단일 책임 원칙 - 데이터 구조만 담당)
// ==========================================
class TodoItem {
  final String id;
  final String title;
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
// 2. ViewModel / State (상태 관리 로직 분리)
// ==========================================
class TodoController extends ChangeNotifier {
  final List<TodoItem> _todos = [
    // 기존 할 일[cite: 1]
    TodoItem(id: '1', title: '5주차 강의 복습'),
    TodoItem(id: '2', title: '상태 흐름도 작성'),
    // 교수가 추가한 할 일 (시험 2주 전)
    TodoItem(id: '3', title: '운영체제 기출문제 3회독'),
    TodoItem(id: '4', title: '알고리즘 정렬 파트 요약 정리'),
    TodoItem(id: '5', title: '밤샘 코딩용 몬스터 에너지 드링크 박스 구매'),
  ];

  List<TodoItem> get todos => _todos;
  
  int get remainingCount => _todos.where((todo) => !todo.isCompleted).length;

  void toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].toggle();
      notifyListeners(); // 상태 변경 알림
    }
  }
}

// ==========================================
// 3. View (UI 렌더링 - DRY 원칙을 지킨 컴포넌트화)
// ==========================================
class CleanTodoApp extends StatelessWidget {
  const CleanTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // 페이스북 스타일 배경색
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
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 할 일', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 상태 요약 섹션
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
            child: Text(
              '남은 할 일 ${_controller.remainingCount}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF007A5E)),
            ),
          ),
          // SNS 피드 스타일 리스트 렌더링
          ..._controller.todos.map((todo) => SnsStyleTodoCard(
            todo: todo,
            onToggle: () => _controller.toggleTodo(todo.id),
          )),
        ],
      ),
    );
  }
}

// ==========================================
// 4. 재사용 가능한 UI 컴포넌트 (DRY 원칙)
// ==========================================
class SnsStyleTodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;

  const SnsStyleTodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 인스타그램/페이스북 피드 느낌의 카드 UI
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
          // 작성자 프로필 느낌의 헤더
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF007A5E),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('컴공과 삼학년', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('방금 전 • 남은 기한 14일'),
            trailing: const Icon(Icons.more_horiz),
          ),
          // 본문 (할 일 내용)
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
          // 하단 액션 버튼 (좋아요/댓글 대신 완료 체크)
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
                    todo.isCompleted ? '완료 취소' : '완료하기', //[cite: 1] 버튼 동작 반영
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