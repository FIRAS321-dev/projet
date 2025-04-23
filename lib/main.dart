import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edubridge/services/auth_service.dart';
import 'package:edubridge/services/question_service.dart';
import 'package:edubridge/services/course_service.dart';
import 'package:edubridge/services/assignment_service.dart';
import 'package:edubridge/services/notification_service.dart';
import 'package:edubridge/screens/splash_screen.dart';
import 'package:edubridge/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => QuestionService()),
        ChangeNotifierProvider(create: (_) => CourseService()),
        ChangeNotifierProvider(create: (_) => AssignmentService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
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
