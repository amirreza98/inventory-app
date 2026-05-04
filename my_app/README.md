dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0

# flutter pub get

# firebase_auth_demo/lib/pages/auth_page.dart

# add logout to the inventory page. Open lib/pages/inventory_page.dart and add a logout button to the AppBar:
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () => FirebaseAuth.instance.signOut(),
    ),
  ],
  bottom: TabBar(
...
import 'package:firebase_auth/firebase_auth.dart';

dependencies:
  cloud_firestore: ^4.15.0

# flutter pub get


# my_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

First add to pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.68.0
  cupertino_icons: ^1.0.8

Then run flutter pub get