import 'package:enova_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:enova_app/screens/splash_screen.dart';
import 'package:enova_app/screens/welcome_screen.dart';
import 'package:enova_app/screens/login_page.dart';
import 'package:enova_app/screens/home_screen.dart' as home;
import 'package:enova_app/screens/notes_screen.dart';
import 'package:enova_app/screens/tasks_screen.dart';
import 'package:enova_app/screens/register_page.dart'; // استيراد صفحة التسجيل

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productivity App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Roboto',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const home.HomeScreen(),
        '/notes': (context) => const NotesScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/register':
            (context) => const RegisterPage(), // إضافة المسار لصفحة التسجيل
      },
    );
  }
}
