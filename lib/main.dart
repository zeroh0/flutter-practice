import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/screens/home_screen.dart';

// Supabase 클라이언트 전역 변수
late final SupabaseClient supabase;

void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load();

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    // 옵션: 오프라인 지원 활성화
    // localStorage: const ChromeLocalStorage(),
    // authFlowType: AuthFlowType.pkce,
  );

  // Supabase 클라이언트 초기화
  supabase = Supabase.instance.client;

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할 일 목록',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
