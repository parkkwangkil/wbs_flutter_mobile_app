// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. 모든 Provider와 Service를 Import 합니다.
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/message_provider.dart';
import 'providers/comment_provider.dart';
import 'services/notification_service.dart';
import 'services/notification_settings.dart'; // 사용자님의 완벽한 그 파일입니다.
import 'services/app_state_service.dart';
import 'services/local_database.dart';

// 2. 시작 페이지를 Import 합니다.
import 'pages/login_page.dart';
import 'pages/create_event_page.dart';
import 'pages/event_detail_page.dart';
import 'pages/notification_settings_page.dart';
import 'pages/project_detail_page.dart';
import 'pages/edit_project_page.dart';

// 비동기 main 함수로 변경합니다.
void main() async {
  // 3. Flutter 엔진과 위젯 바인딩을 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 4. 앱 실행 전 필수 서비스들을 초기화합니다.
  // 이 순서가 매우 중요합니다.
  final languageProvider = await LanguageProvider.initialize();
  final themeProvider = await ThemeProvider.initialize();
  await NotificationSettings.initialize(); // 사용자님의 알림 설정 서비스 초기화
  await NotificationService.initialize();  // 푸시 알림 서비스 초기화
  await LocalDatabase.initialize(); // 로컬 데이터베이스 초기화

  // 5. 앱을 실행합니다.
  runApp(
    // 6. MultiProvider로 모든 Provider를 앱의 최상단에 등록합니다.
    // 이렇게 하면 앱 어디서든 Provider.of<...>(context)로 접근할 수 있습니다.
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => AppStateService()),
      ],
      child: const WbsMobileApp(),
    ),
  );
}

class WbsMobileApp extends StatelessWidget {
  const WbsMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 7. ThemeProvider와 LanguageProvider를 사용하여 앱의 전체 테마와 언어를 관리합니다.
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'WBS Mobile',

          // 테마 설정 (다크/라이트 모드)
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // 다국어 지원 설정 (여기서는 언어 변경만 담당, 실제 텍스트는 각 위젯에서 처리)
          locale: Locale(languageProvider.currentLanguage),
          // 지원할 언어 목록 (필요시 추가)
          // supportedLocales: const [
          //   Locale('ko', ''),
          //   Locale('en', ''),
          // ],

          debugShowCheckedModeBanner: false,

          // 라우트 설정
          routes: {
            '/create_event': (context) => const CreateEventPage(),
            '/event_detail': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return EventDetailPage(
                event: args['event'],
                currentUser: args['currentUser'],
              );
            },
            '/notification_settings': (context) => const NotificationSettingsPage(),
            '/project_detail': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              if (args == null) {
                return const Scaffold(
                  body: Center(child: Text('프로젝트 정보를 찾을 수 없습니다.')),
                );
              }
              return ProjectDetailPage(project: args);
            },
            '/edit_project': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              if (args == null) {
                return const Scaffold(
                  body: Center(child: Text('프로젝트 정보를 찾을 수 없습니다.')),
                );
              }
              return EditProjectPage(project: args);
            },
          },

          // 8. 앱의 첫 시작 화면을 LoginPage로 지정합니다.
          home: const LoginPage(),
        );
      },
    );
  }
}
