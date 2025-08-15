import 'package:flutter/material.dart';
import 'view/auth_gate.dart';
import 'view/login_view.dart';
import 'view/register_view.dart';
import './constants/app_colors.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hỗ Trợ Trẻ Tự Kỷ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.cardBorder),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
      },
    );
  }
}



