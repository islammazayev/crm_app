import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';

/// Appens startpunkt: inloggningen om ingen är inloggad, annars rätt
/// startsida för användarens roll.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

/// Startar om från [AuthGate] och tar bort alla sidor under.
///
/// Används efter registrering och vid utloggning, så att appen alltid
/// hamnar på rätt startsida även om man har navigerat bort från den.
void restartFromAuthGate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AuthGate()),
    (route) => false,
  );
}

/// Loggar ut och visar inloggningen.
Future<void> signOutToLogin(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) restartFromAuthGate(context);
}
