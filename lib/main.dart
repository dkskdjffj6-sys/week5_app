import 'package:flutter/material.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '과제 5주차 - 상태 기능과 작업 컨텍스트',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskManagerScreen(),
    );
  }
}

/// [데이터 모델]
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

/// [상태 관리 및 UI 화면]
class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  // 1. 원본 상태 (Source of Truth)
  final List<TaskItem> _tasks = [
    const TaskItem(id: '1', title: '5주차 과제 CONTEXT_PACKET.md 작성'),
    const TaskItem(id: '2', title: 'Flutter 상태 기능 및 이벤트 바인딩'),
    const TaskItem(id: '3', title: 'flutter analyze 검증 및 Git commit'),
  ];

  // 2. 계산값 (Derived State - AC4 준수)
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  double get progressRate => totalCount == 0 ? 0.0 : completedCount / totalCount;

  // 3. 이벤트 처리 메서드
  void _toggleTaskStatus(String id) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 상태 관리 (5주차)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ), // <-- AppBar 괄호가 여기서 완전히 닫혀야 body가 Scaffold 속성으로 정상 인식됩니다.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 진행률 요약 카운터
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '전체 진행률',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$completedCount / $totalCount 완료 (${(progressRate * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progressRate,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 작업 리스트
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CheckboxListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      value: task.isCompleted,
                      onChanged: (_) => _toggleTaskStatus(task.id),
                    ),
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