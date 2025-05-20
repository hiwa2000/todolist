import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart'; // Add to pubspec.yaml

void main() {
  runApp(const TodoApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

// ======================= APP CORE =======================
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef To-Do',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Auto dark/light
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade600,
          secondary: Colors.orange.shade400,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade300,
          secondary: Colors.orange.shade300,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// ======================= AUTH WRAPPER =======================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false; // Simulated auth state

  void _toggleAuth(bool success) {
    setState(() {
      _isLoggedIn = success;
      if (success) _showConfetti();
    });
  }

  final ConfettiController _confettiController = ConfettiController();

  void _showConfetti() {
    _confettiController.play();
    Future.delayed(const Duration(seconds: 2), _confettiController.stop);
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
          _isLoggedIn ? const TodoScreen() : LoginScreen(onLogin: _toggleAuth),

          // Confetti Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= LOGIN SCREEN =======================
class LoginScreen extends StatelessWidget {
  final Function(bool) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            Hero(
              tag: 'app-logo',
              child: Icon(
                Icons.restaurant_menu,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Cook with Chef',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to manage your recipes',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 32),

            // Login Form
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => onLogin(true), // Simulate successful login
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= TODO SCREEN =======================
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  void _addTodo() {
    if (_todoController.text.trim().isEmpty) return;
    setState(() {
      _todos.insert(0, _todoController.text.trim());
      _todoController.clear();
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
            ),
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
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Todo List
          Expanded(
            child: _todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          size: 60,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes yet!\nStart adding some magic.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_todos[index]),
                        background: Container(color: Colors.red.shade200),
                        onDismissed: (_) => _deleteTodo(index),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(_todos[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTodo(index),
                            ),
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