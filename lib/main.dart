import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/main_shell.dart'; // New: the tab shell that wraps all logged-in screens
import 'pages/auth_page.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() must be called before any async
  // work in main() so Flutter's rendering engine is ready before Firebase starts.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the auto-generated firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // StreamBuilder listens to Firebase Auth state changes.
      // It rebuilds automatically when the user logs in or logs out — no manual navigation needed.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While Firebase checks whether a session already exists, show a spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // snapshot.hasData is true when a User object is present (logged in)
          if (snapshot.hasData) {
            // Logged in → go to MainShell (bottom nav + all tabs)
            return const MainShell();
          }

          // Not logged in → go to the login / register screen
          return const AuthPage();
        },
      ),
    );
  }
}
