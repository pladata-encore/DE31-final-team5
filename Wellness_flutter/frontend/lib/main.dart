//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/features/authentication/views/height_screen.dart';
import 'package:frontend/features/authentication/views/login_screen.dart';
import 'package:frontend/features/authentication/views/signup_screen.dart';
import 'package:frontend/features/authentication/views/birthday_screen.dart';
import 'package:frontend/features/authentication/views/gender_screen.dart';
import 'package:frontend/features/authentication/views/weight_screen.dart';
import 'package:frontend/features/home/views/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/home/views/analyze_page.dart';
import 'package:frontend/features/home/views/record_screen.dart';
import 'package:image_picker/image_picker.dart'; // AnalyzePage import
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // SystemChrome import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import
import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:http/http.dart' as http; // HTTP 패키지

final Logger logger = Logger(); // Logger 인스턴스 생성

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  final Logger logger = Logger(); // Logger 인스턴스 생성
  WidgetsFlutterBinding.ensureInitialized(); // 플러그인 초기화
  final prefs = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env"); // .env 파일 로드

  ///화면 세로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // signUp 변수가 없으면 false로 설정
  if (!prefs.containsKey('signUp')) {
    await prefs.setBool('signUp', false);
    logger.i('signup이 false로 초기화됨');
  } else {
    logger.i('signup 값이 이미 존재');
  }

  bool signUp = prefs.getBool('signUp') ?? false;
  logger.i('SharedPreferences에서 signUp 값: $signUp');

  // 2초 동안 스플래시 화면 유지
  await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

  FlutterNativeSplash.remove(); // 스플래시 화면 제거

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 투명한 상태바 설정
    statusBarIconBrightness: Brightness.dark, // 상태바 아이콘을 어두운 색으로 설정
  ));

  await dotenv.load(fileName: '.env');
  String? kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];

  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  logger.i('Kakao SDK initialized'); // Kakao SDK 초기화 로그

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    ProviderScope(
      child: MyApp(
        initialRoute: signUp
            ? HomeScreen.routeURL
            : SignupScreen.routeURL, // signUp 여부에 따라 초기 경로 설정
      ),
    ),
  );
  logger
      .i('초기 경로 설정됨: ${signUp ? HomeScreen.routeURL : SignupScreen.routeURL}');
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'WELLNESS',
      theme: ThemeData(
        primaryColor: const Color(0xff28B0EE),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Korean
      ],
      locale: const Locale('ko'), // 기본 로케일 설정
      routerConfig: GoRouter(
        initialLocation: widget.initialRoute,
        routes: _routes(),
      ),
    );
  }

  List<GoRoute> _routes() {
    return [
      GoRoute(
        name: SignupScreen.routeName,
        path: SignupScreen.routeURL,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        name: LoginScreen.routeName,
        path: LoginScreen.routeURL,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: BirthdayScreen.routeName,
        path: BirthdayScreen.routeURL,
        builder: (context, state) => const BirthdayScreen(),
      ),
      GoRoute(
        name: GenderScreen.routeName,
        path: GenderScreen.routeURL,
        builder: (context, state) => const GenderScreen(),
      ),
      GoRoute(
        name: HeightScreen.routeName,
        path: HeightScreen.routeURL,
        builder: (context, state) => const HeightScreen(),
      ),
      GoRoute(
        name: WeightScreen.routeName,
        path: WeightScreen.routeURL,
        builder: (context, state) => const WeightScreen(),
      ),
      GoRoute(
        name: HomeScreen.routeName,
        path: HomeScreen.routeURL,
        builder: (context, state) {
          final tab = state.pathParameters['tab'] ?? 'home'; // 탭 값 가져오기
          return HomeScreen(tab: tab);
        },
      ),
      GoRoute(
        path: '/analyze',
        builder: (context, state) {
          final image = state.extra as XFile;
          return AnalyzePage(image: image);
        },
      ),
      GoRoute(
        path: '/home/record',
        builder: (context, state) {
          return const RecordScreen(
            isLatestFirst: true,
          );
        },
      ),
    ];
  }
}
