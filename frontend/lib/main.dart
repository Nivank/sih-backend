import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/transliteration_screen.dart';
import 'state/auth_state.dart';
import 'utils/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env');
  runApp(const BharatApp());
}

class BharatApp extends StatelessWidget {
  const BharatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: UiConstants.appName,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomeScaffold(),
      ),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _index = 0;
  Map<String, dynamic>? _noteToFocus;
  String _editableTitle = UiConstants.appName; // Editable title
  bool _showDebugInfo = false; // Debug info toggle
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    // Initialize screens with callbacks
    _screens = [
      const LoginScreen(),
      const TransliterationScreen(),
      NotesScreen(onViewOnMap: _navigateToMapWithNote),
      MapScreen(noteToFocus: _noteToFocus, onNoteFocused: _clearNoteToFocus),
    ];
    
    // Load stored JWT if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthState>().loadToken();
    });
  }
  
  void _navigateToMapWithNote(Map<String, dynamic> note) {
    setState(() {
      _noteToFocus = note;
      _index = 3; // Map tab index
    });
  }
  
  void _clearNoteToFocus() {
    setState(() {
      _noteToFocus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _showTitleEditDialog(),
              onLongPress: () => setState(() => _showDebugInfo = !_showDebugInfo),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _editableTitle,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      // Login status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: authState.isAuthenticated ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authState.isAuthenticated ? 'LOGGED IN' : 'LOGGED OUT',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Debug info
                  if (_showDebugInfo) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Debug: API=${AppConfig.apiBaseUrl} | Auth=${authState.isAuthenticated} | Screen=$_index',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              // Quick title edit button
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: _showTitleEditDialog,
                tooltip: 'Edit Title',
              ),
              // Debug toggle button
              IconButton(
                icon: Icon(
                  _showDebugInfo ? Icons.bug_report : Icons.visibility_off,
                  size: 20,
                ),
                onPressed: () => setState(() => _showDebugInfo = !_showDebugInfo),
                tooltip: 'Toggle Debug Info',
              ),
            ],
          ),
          body: _screens[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.login), label: UiConstants.loginLabel),
              BottomNavigationBarItem(icon: Icon(Icons.translate), label: UiConstants.transliterateLabel),
              BottomNavigationBarItem(icon: Icon(Icons.note_add), label: UiConstants.notesLabel),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: UiConstants.mapLabel),
            ],
          ),
        );
      },
    );
  }

  void _showTitleEditDialog() {
    final controller = TextEditingController(text: _editableTitle);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Edit App Title'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'App Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tip: Long press title to toggle debug info',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _editableTitle = controller.text.isNotEmpty 
                    ? controller.text 
                    : UiConstants.appName;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}