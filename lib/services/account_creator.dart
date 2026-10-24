import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Skapar ett inloggningskonto åt någon annan (manager, kassör) utan att
/// admin loggas ut.
///
/// `createUserWithEmailAndPassword` loggar in det nya kontot på den
/// FirebaseApp det anropas på, så kontot skapas på en tillfällig sekundär
/// app-instans. [writeProfile] körs sedan med admins vanliga inloggning
/// (reglerna kräver admin för att skapa managers och kassörer). Misslyckas
/// den tas kontot bort igen, så att e-postadressen inte blir blockerad.
Future<String> createAccountAsAdmin({
  required String email,
  required String password,
  required Future<void> Function(String uid) writeProfile,
}) async {
  FirebaseApp? secondaryApp;
  try {
    secondaryApp = await Firebase.initializeApp(
      name: 'account-creator-${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final cred = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final newUser = cred.user!;
    try {
      await writeProfile(newUser.uid);
    } catch (_) {
      await newUser.delete();
      rethrow;
    }
    await secondaryAuth.signOut();
    return newUser.uid;
  } finally {
    try {
      await secondaryApp?.delete();
    } catch (_) {}
  }
}
