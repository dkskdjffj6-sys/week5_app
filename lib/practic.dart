import 'package:flutter/material.dart';

void main() {
  runApp(const CleanTodoApp());
}

// ==========================================
// 1. Model (데이터 구조 - 단일 책임 원칙)
// ==========================================
class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  bool isLiked;
  String? imageUrl;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isLiked = false,
    this.imageUrl,
  });

  void toggleCompleted() => isCompleted = !isCompleted;
  void toggleLiked() => isLiked = !isLiked;
}

// ==========================================
// 2. ViewModel / State (상태 관리자)
// ==========================================
class TodoController extends ChangeNotifier {
  final List<TodoItem> _todos = [
    TodoItem(id: '1', title: '5주차 강의 복습 #플러터 #복습'),
    TodoItem(id: '2', title: '상태 흐름도 작성 완료 인증샷!', imageUrl: 'https://picsum.photos/400/200?random=1'), 
    TodoItem(id: '3', title: '운영체제 기출문제 3회독 #운영체제 #시험기간'),
  ];

  List<TodoItem> get todos => _todos;
  int get remainingCount => _todos.where((todo) => !todo.isCompleted).length;

  void addTodo(String title, {String? imageUrl}) {
    if (title.trim().isEmpty) return;
    _todos.insert(0, TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      imageUrl: imageUrl,
    ));
    notifyListeners();
  }

  void updateTodo(String id, String newTitle) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].title = newTitle;
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTodoCompleted(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].toggleCompleted();
      notifyListeners();
    }
  }

  void toggleTodoLiked(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].toggleLiked();
      notifyListeners();
    }
  }
}
// ==========================================
// 3. View & Theme (DRY 원칙 - 테마 및 앱 껍데기)
// ==========================================
class CleanTodoApp extends StatelessWidget {
  const CleanTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007A5E),
          surface: const Color(0xFFF0F2F5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTodoDialog({String? id, String? currentTitle}) {
    final textController = TextEditingController(text: currentTitle);
    final isEditing = id != null;
    bool attachMockImage = false; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? '할 일 수정' : '새 게시물 작성'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(hintText: '무엇을 할 건가요? (#태그 지원)'),
                  autofocus: true,
                  maxLines: 3,
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: attachMockImage,
                        onChanged: (val) => setDialogState(() => attachMockImage = val ?? false),
                      ),
                      const Text('완료 인증용 샘플 사진 첨부'),
                    ],
                  )
                ]
              ],
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
                    final imgUrl = attachMockImage 
                      ? 'https://picsum.photos/400/200?random=${DateTime.now().millisecondsSinceEpoch}' 
                      : null;
                    _controller.addTodo(textController.text, imageUrl: imgUrl);
                  }
                  Navigator.pop(context);
                },
                child: Text(isEditing ? '수정완료' : '게시'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('나의 할 일')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
            child: Text(
              '남은 할 일 ${_controller.remainingCount}',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ..._controller.todos.map((todo) => SnsStyleTodoCard(
            todo: todo,
            onToggleComplete: () => _controller.toggleTodoCompleted(todo.id),
            onToggleLike: () => _controller.toggleTodoLiked(todo.id),
            onEdit: () => _showTodoDialog(id: todo.id, currentTitle: todo.title),
            onDelete: () => _controller.deleteTodo(todo.id),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('게시물 작성'),
      ),
    );
  }
}
// ==========================================
// 4. 위젯 세분화 (단일 책임 원칙 - 유지보수성 극대화)
// ==========================================
class SnsStyleTodoCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleLike;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SnsStyleTodoCard({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onToggleLike,
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
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(onEdit: onEdit, onDelete: onDelete),
          CardBody(title: todo.title, isCompleted: todo.isCompleted, imageUrl: todo.imageUrl),
          const Divider(height: 1),
          CardFooter(
            isCompleted: todo.isCompleted,
            isLiked: todo.isLiked,
            onToggleComplete: onToggleComplete,
            onToggleLike: onToggleLike,
          ),
        ],
      ),
    );
  }
}

// 4-1. Header
class CardHeader extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardHeader({super.key, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: const Text('컴공과 2학년', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('방금 전 • 기말 D-14'),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('수정하기')),
          const PopupMenuItem(value: 'delete', child: Text('삭제하기', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

// 4-2. Body
class CardBody extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final String? imageUrl;

  const CardBody({super.key, required this.title, required this.isCompleted, this.imageUrl});

  List<TextSpan> _parseHashtags(String text, BuildContext context) {
    final words = text.split(' ');
    return words.map((word) {
      final isHashtag = word.startsWith('#');
      return TextSpan(
        text: '$word ',
        style: TextStyle(
          color: isHashtag ? Colors.blue : (isCompleted ? Colors.grey : Colors.black87),
          fontWeight: isHashtag ? FontWeight.bold : FontWeight.normal,
          decoration: isCompleted && !isHashtag ? TextDecoration.lineThrough : null,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: _parseHashtags(title, context),
            ),
          ),
        ),
        if (imageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.network(
              imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}
// 4-3. Footer
class CardFooter extends StatelessWidget {
  final bool isCompleted;
  final bool isLiked;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleLike;

  const CardFooter({
    super.key,
    required this.isCompleted,
    required this.isLiked,
    required this.onToggleComplete,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          AnimatedHeartButton(isLiked: isLiked, onTap: onToggleLike),
          const SizedBox(width: 24),
          InkWell(
            onTap: onToggleComplete,
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  isCompleted ? '완료 취소' : '할 일 완료',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 4-4. 하트 애니메이션 버튼
class AnimatedHeartButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;

  const AnimatedHeartButton({super.key, required this.isLiked, required this.onTap});

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '좋아요',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.isLiked ? Colors.red : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}