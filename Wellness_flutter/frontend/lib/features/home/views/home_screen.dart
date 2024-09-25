import 'package:flutter/material.dart';
import 'package:frontend/constants/gaps.dart';
import 'package:frontend/constants/sizes.dart';
import 'package:frontend/features/home/views/widgets/nav_tab.dart';
import 'package:frontend/features/home/views/widgets/nutrition_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'record_screen.dart';
import 'package:frontend/features/home/repos/nutrition_repository.dart'; // 리포지토리 추가
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
//import 'package:frontend/features/authentication/view_models/kakao_login.dart';
//import 'package:frontend/features/authentication/views/login_screen.dart';
import 'package:frontend/features/home/providers/token_manager.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "home";
  static const String routeURL = "/home/:tab";

  final String tab;

  const HomeScreen({
    super.key,
    required this.tab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double intakeRatio = 0.0;
  final List<String> tabs = ["home", "record"];
  Map<String, dynamic> jsonData = {
    'user_nickname': '이름', // 기본 닉네임
    'total_kcal': 0, // 기본 섭취 칼로리
    'rec_kcal': 2000, // 기본 권장 칼로리
    'total_car': 0, // 기본 탄수화물 섭취
    'total_prot': 0, // 기본 단백질 섭취
    'total_fat': 0, // 기본 지방 섭취
    'rec_car': 300, // 기본 탄수화물 권장량
    'rec_prot': 50, // 기본 단백질 권장량
    'rec_fat': 70, // 기본 지방 권장량
  }; // 기본값 설정

  final NutritionRepository nutritionRepository =
      NutritionRepository(); // API 리포지토리

  bool _isLoading = true; // 로딩상태 관리
  final bool _isLatestFirst = true; // 정렬 상태
  late int _selectedIndex;
  bool _isRequestingPermission = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getIndexFromTab(widget.tab);

    // tokenManager 인스턴스 생성
    final tokenManager = TokenManager(context: context);

    tokenManager.refreshToken().then((_) {
      _loadNutritionData(); // 데이터를 로드
    });

    // 5초 후 로딩을 중단하고 기본 값을 보여주도록 설정
    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false; // 5초 후 로딩 상태를 해제하고 기본값을 보여줌
        });
      }
    });
  }

  // API에서 데이터 받기
  Future<void> _loadNutritionData() async {
    try {
      // fetchNutritionData 메소드 호출 시 토큰 전달
      final response = await nutritionRepository.fetchNutritionData();

      // 응답에서 필요한 데이터 파싱
      final detail = response['detail']['wellness_recommend_info'];
      logger.i('++++++++++++++++++in 0++++++++++++++++++');

      if (mounted) {
        setState(() {
          jsonData = {
            'user_nickname': detail['user_nickname'] ?? "이름", //닉네임
            'total_kcal': detail['total_kcal'] ?? 0, // 섭취 칼로리
            'total_car': detail['total_car'] ?? 0, // 섭취 탄수화물
            'total_prot': detail['total_prot'] ?? 0, // 섭취 단백질
            'total_fat': detail['total_fat'] ?? 0, // 섭취 지방
            'rec_kcal': detail['rec_kcal'] ?? 2000, // 권장 칼로리
            'rec_car': detail['rec_car'] ?? 300, // 권장 탄수화물
            'rec_prot': detail['rec_prot'] ?? 50, // 권장 단백질
            'rec_fat': detail['rec_fat'] ?? 70, // 권장 지방
          };
          _isLoading = false; // 데이터를 성공적으로 받으면 로딩 해제
          logger.i('홈 화면 응답 : $jsonData');
        });
      }
    } catch (e) {
      debugPrint("데이터를 불러오는 중 오류 발생(home_screen): $e");
      // 오류가 발생하면 기본값을 그대로 사용
      if (mounted) {
        setState(() {
          _isLoading = false; // 오류가 발생해도 로딩 해제
        });
      }
    }
  }

  // // 로그아웃 처리
  // Future<void> _logout() async {
  //   try {
  //     await KakaoLoginService().signOut(); // 카카오 로그아웃 호출
  //     // 로그아웃 후 로그인 화면으로 이동
  //     context.go(LoginScreen.routeURL);
  //   } catch (e) {
  //     // 에러 처리
  //     print('로그아웃 실패: $e');
  //   }
  // }

  //progress bar 색상설정
  Color _getProgressColor(double intakeRatio) {
    if (intakeRatio < 0.5) {
      return const Color.fromARGB(255, 255, 179, 80); // 50% 이하일 때 초록색
    } else if (intakeRatio >= 0.5 && intakeRatio < 0.75) {
      return const Color.fromARGB(255, 97, 170, 87); // 50%에서 80% 사이일 때 노란색
    } else if (intakeRatio >= 0.75 && intakeRatio <= 1.0) {
      return const Color.fromARGB(255, 68, 143, 255); // 80%에서 100% 사이일 때 주황색
    } else {
      return const Color.fromARGB(255, 255, 61, 87); // 100% 초과 시 빨간색
    }
  }

  int _getIndexFromTab(String tab) {
    switch (tab) {
      case "home":
        return 0;
      case "record":
        return 1;
      default:
        return 0;
    }
  }

  // 이미지 선택 권한
  Future<void> _pickImage() async {
    if (_isRequestingPermission) return;

    _isRequestingPermission = true;

    try {
      var status = await Permission.storage.status;
      if (await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image != null && mounted) {
          context.go('/analyze', extra: image);
        }
      } else {
        status = await Permission.photos.request();
        if (status.isGranted) {
          final ImagePicker picker = ImagePicker();
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);

          if (image != null && mounted) {
            context.go('/analyze', extra: image);
          }
        } else if (status.isDenied || status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('갤러리 접근 권한이 필요합니다.'),
              action: SnackBarAction(
                label: '설정으로 이동',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } finally {
      _isRequestingPermission = false;
    }
  }

  // tab이 눌릴 떄 마다 데이터 받기
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final tokenManager = TokenManager(context: context);
    tokenManager.refreshToken().then((_) {
      // 홈 탭(인덱스 0)이 선택될 때마다 데이터를 다시 불러옴
      if (index == 0) {
        _loadNutritionData(); // 홈 탭이 선택될 때마다 데이터를 새로 받아옴
      }
    });

    String selectedTab = tabs[index];
    context.go('/home/$selectedTab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(), // AppBar를 동적으로 설정
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // 화면 내용 표시
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(), // 로딩 중일 때 로딩 애니메이션 표시
                      )
                    : _buildHomeScreen(context), // 로딩이 완료되면 홈 화면 표시
                RecordScreen(
                  isLatestFirst: _isLatestFirst,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 232, 245, 233), // 앱바 색상 고정
          elevation: 0,
          centerTitle: true,
          title: Text(
            _selectedIndex == 0 ? "WELLNESS" : "오늘 식단",
            style: const TextStyle(
              fontSize: 23,
              fontFamily: "appname",
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black, // 아이콘 색상 고정
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white, // 상태바 배경색 고정
            statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 고정
          ),
          // actions: [
          //   if (_selectedIndex == 0)
          //     GestureDetector(
          //       onTap: _logout, // 로그아웃 기능 연결
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 16), // 텍스트 간격 조정
          //         child: Center(
          //           child: Text(
          //             "로그아웃",
          //             style: TextStyle(
          //               fontFamily: "pretendard-regular",
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //               color: Colors.red, // 로그아웃 텍스트 색상
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          // ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    String nickname = jsonData['user_nickname'] ?? "이름";
    int totalKcal = (jsonData['total_kcal'] ?? 0).toInt();
    int recKcal = (jsonData['rec_kcal'] ?? 0).toInt();
    double intakeRatio = totalKcal / recKcal;
    int remainingCalories = recKcal - totalKcal;

    int totalCar = (jsonData['total_car'] ?? 0).toInt();
    int totalProt = (jsonData['total_prot'] ?? 0).toInt();
    int totalFat = (jsonData['total_fat'] ?? 0).toInt();

    int recCar = (jsonData['rec_car'] ?? 0).toInt();
    int recProt = (jsonData['rec_prot'] ?? 0).toInt();
    int recFat = (jsonData['rec_fat'] ?? 0).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 25, right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gaps.v14,
          Align(
            alignment: Alignment.center,
            child: Text(
              "$nickname 님",
              style: const TextStyle(
                fontFamily: "myfonts",
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Gaps.v10,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$totalKcal",
                      style: const TextStyle(
                        fontFamily: "appname",
                        fontSize: 30,
                        color: Color.fromARGB(221, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: " / ",
                      style: TextStyle(
                        fontFamily: "myfonts",
                        fontSize: 18,
                        color: Color.fromARGB(221, 0, 0, 0),
                      ),
                    ),
                    TextSpan(
                      text: "$recKcal kcal",
                      style: const TextStyle(
                        fontFamily: "myfonts",
                        fontSize: 18,
                        color: Color.fromARGB(221, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Gaps.v32,
                  SizedBox(
                    height: 200.0,
                    width: 200.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 13.0,
                          animation: true,
                          animationDuration: 1500,
                          percent: intakeRatio > 1 ? 1.0 : intakeRatio,
                          center: SizedBox(
                            height: 40.0,
                            child: Center(
                              child: Text(
                                "${(intakeRatio * 100).round()}%",
                                style: const TextStyle(
                                  fontFamily: "myfonts",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 27.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor:
                              const Color.fromARGB(132, 143, 165, 206),
                          progressColor: _getProgressColor(intakeRatio),
                          backgroundWidth: 8,
                        ),
                        if (intakeRatio > 1)
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            animationDuration: 1500,
                            percent: (intakeRatio - 1).clamp(0, 1),
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.transparent,
                            progressColor:
                                const Color.fromARGB(255, 255, 61, 87),
                            backgroundWidth: 5,
                          ),
                      ],
                    ),
                  ),
                  Gaps.v32,
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: "myfonts",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: remainingCalories > 0
                              ? "$remainingCalories kcal"
                              : "너무 많이 먹는 건 건강에 좋지 않아요🥲",
                          style: TextStyle(
                            fontFamily: "myfonts",
                            color: remainingCalories > 0
                                ? const Color.fromARGB(221, 0, 160, 13)
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (remainingCalories > 0)
                          const TextSpan(
                            text: " 더 먹을 수 있어요!",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Gaps.v32,
                  NutritionBar(
                    label: "탄수화물",
                    intake: totalCar,
                    recommended: recCar,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 156, 194, 255),
                        Color.fromARGB(255, 48, 97, 255)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  Gaps.v8,
                  NutritionBar(
                    label: "단백질",
                    intake: totalProt,
                    recommended: recProt,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(195, 255, 241, 181),
                        Color.fromARGB(255, 255, 195, 30)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  Gaps.v8,
                  NutritionBar(
                    label: "지방",
                    intake: totalFat,
                    recommended: recFat,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 160, 192),
                        Color.fromARGB(255, 255, 56, 156)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 232, 245, 233),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).padding.bottom > 0
              ? Sizes.size8
              : Sizes.size12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavTab(
              text: "오늘 하루",
              isSelected: _selectedIndex == 0,
              icon: FontAwesomeIcons.houseUser,
              onTap: () => _onTap(0),
              selectedIcon: FontAwesomeIcons.houseUser,
            ),
            Gaps.h48,
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 138, 26),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const FaIcon(
                  size: 30,
                  FontAwesomeIcons.camera,
                  color: Colors.white,
                ),
              ),
            ),
            Gaps.h48,
            NavTab(
              text: "오늘 식단",
              isSelected: _selectedIndex == 1,
              icon: FontAwesomeIcons.utensils,
              onTap: () => _onTap(1),
              selectedIcon: FontAwesomeIcons.utensils,
            ),
          ],
        ),
      ),
    );
  }
}
