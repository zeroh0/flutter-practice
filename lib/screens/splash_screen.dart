import 'package:flutter/material.dart';
import 'package:todo/main.dart';

import 'auth_screen.dart';
import 'home_screen.dart';

// 앱 초기 라우팅 화면 - 로그인 상태 확인
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final session = supabase.auth.currentSession;

    // 1초 지연 후 라우팅 (스플래시 화면 표시용)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (session != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
