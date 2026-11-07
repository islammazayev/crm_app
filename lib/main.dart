import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/auth_gate.dart';
import 'theme/app_palettes.dart';
import 'theme/app_theme.dart';
import 'theme/text_size_controller.dart';
import 'theme/theme_controller.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const macosSettings = DarwinInitializationSettings();

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: macosSettings,
  );

  await localNotifications.initialize(initSettings);

  await LocaleController.instance.load();
  await ThemeController.instance.load();
  await TextSizeController.instance.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Färgerna läses direkt av alla sidor, så hela appen byggs om när
    // temat byts (nyckeln). Man hamnar då på sin startsida igen.
    return ValueListenableBuilder<AppPalette>(
      valueListenable: ThemeController.instance,
      builder: (context, palette, _) => ValueListenableBuilder<Locale?>(
        valueListenable: LocaleController.instance,
        builder: (context, locale, _) => MaterialApp(
          key: ValueKey(palette.id),
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.current,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: LocaleController.resolve,
          // Vald textstorlek gånger telefonens egen.
          builder: (context, child) => ValueListenableBuilder<double>(
            valueListenable: TextSizeController.instance,
            builder: (context, size, _) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(
                    media.textScaler.scale(14) / 14 * size,
                  ),
                ),
                child: child!,
              );
            },
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
