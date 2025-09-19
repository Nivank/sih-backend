import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'utils/config.dart';
import 'state/auth_state.dart';
import 'screens/login_screen.dart';
import 'screens/transliteration_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/map_screen.dart';

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
  final _screens = const [
    LoginScreen(),
    TransliterationScreen(),
    NotesScreen(),
    MapScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load stored JWT if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthState>().loadToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(UiConstants.appName)),
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: 'Transliterate'),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
    );
  }
}
