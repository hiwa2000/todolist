import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const TodoApp());
}

// ======================= MAIN APP =======================
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef To-Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.teal.shade600, // Updated primary color
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// ======================= AUTH HANDLER =======================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  final ConfettiController _confettiController = ConfettiController();

  void _login() {
    setState(() => _isLoggedIn = true);
    _confettiController.play();
    Future.delayed(const Duration(seconds: 2), _confettiController.stop);
  }

  void _logout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          _isLoggedIn 
              ? TodoScreen(onLogout: _logout) 
              : LoginScreen(onLogin: _login),

          // Confetti Effect (on login)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 90, // Falls from top
              emissionFrequency: 0.05,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= LOGIN SCREEN =======================
class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Icon(
              Icons.restaurant,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Chef To-Do',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One-click login for demo',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 32),

            // Sign In Button (No credentials needed)
            FilledButton(
              onPressed: onLogin, // Instant login
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.teal.shade600,
              ),
              child: const Text('Sign In Instantly'),
            ),

            // Optional: Bypass text
            const SizedBox(height: 16),
            TextButton(
              onPressed: onLogin,
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= TODO SCREEN =======================
class TodoScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const TodoScreen({super.key, required this.onLogout});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  void _addTodo() {
    if (_todoController.text.trim().isNotEmpty) {
      setState(() {
        _todos.add(_todoController.text.trim());
        _todoController.clear();
      });
    }
  }

  void _deleteTodo(int index) {
    setState(() => _todos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Todo Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Add a new recipe...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _addTodo,
                  backgroundColor: Colors.teal.shade600,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),

          // Todo List
          Expanded(
            child: _todos.isEmpty
                ? const Center(
                    child: Text('No recipes added yet!'),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(_todos[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTodo(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}