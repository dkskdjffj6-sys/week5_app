import 'package:flutter/material.dart';

// 1. 앱의 진입점 (Main Entrypoint)
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskManagerScreen(),
    );
  }
}

// 2. Immutable State Model (상태 계약)
@immutable
class TaskItem {
  final String id;
  final String title;
  final bool isCompleted;

  const TaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  TaskItem copyWith({bool? isCompleted}) {
    return TaskItem(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// 3. 상태 관리 화면 컴포넌트
class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  // Source of Truth (원본 상태 소유)
  final List<TaskItem> _tasks = [
    const TaskItem(id: '1', title: 'Flutter 상태 계약서 작성하기', isCompleted: true),
    const TaskItem(id: '2', title: 'Context Packet 문서화', isCompleted: false),
    const TaskItem(id: '3', title: 'PROMPT_COMPARISON 작성', isCompleted: false),
  ];

  // Computed Values (계산값 - 원본 상태를 파생하여 사용, AC4 만족)
  int get _totalCount => _tasks.length;
  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  // Event Handler (이벤트 -> 상태 변경)
  void _handleToggleTask(String id, bool? value) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isCompleted: value ?? false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 컨텍스트 및 상태 관리 과제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 패널 (계산값 활용)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('전체 작업: $_totalCount개', style: const TextStyle(fontSize: 16)),
                    Text('완료됨: $_completedCount개', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('할 일 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // 리스트 뷰 (UI State 렌더링)
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks.indexWhere((t) => t.id == _tasks[index].id); // 안전한 참조
                  final currentTask = _tasks[index];
                  return CheckboxListTile(
                    title: Text(
                      currentTask.title,
                      style: TextStyle(
                        decoration: currentTask.isCompleted ? TextDecoration.lineThrough : null,
                        color: currentTask.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    value: currentTask.isCompleted,
                    onChanged: (bool? value) => _handleToggleTask(currentTask.id, value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}