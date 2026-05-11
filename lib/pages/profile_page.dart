import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ProfilePage shows the logged-in user's details and a sign-out button.
// It is opened by tapping the avatar in the MainShell AppBar.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.currentUser is never null here because
    // MainShell is only shown when a user is logged in (StreamBuilder in main.dart).
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown';

    // Use the first letter of the email as the avatar initial.
    // toUpperCase() makes it a capital letter.
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Flutter adds the back arrow automatically for pushed screens
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // Large avatar showing the user's initial
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Show the full email address
            Text(
              email,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Logged in user',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 16),

            // Sign Out button — calls signOut() which clears the Firebase session.
            // The StreamBuilder in main.dart detects the change and shows the login screen.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
