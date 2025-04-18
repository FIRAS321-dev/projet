import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:edubridge/screens/splash_screen.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:edubridge/services/firebase_initializer.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }

  // Décommentez cette ligne pour initialiser la base de données avec des données de test
  await FirebaseInitializer().initializeDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
