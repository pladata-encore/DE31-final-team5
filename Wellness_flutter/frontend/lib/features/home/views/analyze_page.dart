import 'package:flutter/material.dart';
import 'package:frontend/constants/sizes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/home/views/widgets/nutrition_bar.dart';
import 'package:frontend/features/home/repos/analyze_repository.dart';
import 'package:logger/logger.dart';
import 'package:frontend/features/home/providers/token_manager.dart';

class AnalyzePage extends StatefulWidget {
  final XFile image;

  const AnalyzePage({
    super.key,
    required this.image,
  });

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  String foodName = "분석 중...";
  String mealtype = "분석 중...";
  int foodKcal = 0;
  int foodCarb = 0;
  int foodProt = 0;
  int foodFat = 0;
  int recKcal = 2000;
  int recCarb = 300;
  int recProt = 50;
  int recFat = 70;

  final AnalyzeRepository analyzeRepository = AnalyzeRepository();
  final Logger logger = Logger();

  bool _isLoading = true; // 데이터 로딩 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();

    // TokenManager 인스턴스 생성
    final tokenManager = TokenManager(context: context);

    tokenManager.refreshToken().then((_) {
      _uploadImageAndLoadFoodData();
    });
  }

  Future<void> _uploadImageAndLoadFoodData() async {
    try {
      // JSON 데이터를 받아옵니다.
      final Map<String, dynamic> jsonData = await analyzeRepository
          .uploadImageAndFetchData(File(widget.image.path), context);

      // API 응답 전체를 로그에 출력하여 확인
      logger.i('API 응답: $jsonData');

      setState(() {
        var wellnessData = jsonData['detail']['wellness_image_info'];

        foodName = wellnessData['category_name'] ?? "음식 정보 없음";
        mealtype = wellnessData['meal_type'] ?? '식사 타입 없음';

        foodKcal = (wellnessData['food_kcal'] ?? 0).toInt();
        foodCarb = (wellnessData['food_car'] ?? 0).toInt();
        foodProt = (wellnessData['food_prot'] ?? 0).toInt();
        foodFat = (wellnessData['food_fat'] ?? 0).toInt();

        recKcal = (wellnessData['rec_kcal'] ?? 2000).toInt();
        recCarb = (wellnessData['rec_car'] ?? 300).toInt();
        recProt = (wellnessData['rec_prot'] ?? 50).toInt();
        recFat = (wellnessData['rec_fat'] ?? 70).toInt();

        _isLoading = false;

        // logger.i(
        //     'foodKcal : $foodKcal / foodCarb: $foodCarb / foodProt : $foodProt / foodFat : $foodFat ');

        // logger.i(
        //     'recKcal : $recKcal / recCarb : $recCarb / recProt : $recProt / recFat : $recFat ');
      });
    } catch (e) {
      logger.e('API 데이터를 불러오는 중 오류 발생(analyze): $e'); // 오류 로그
      setState(() {
        foodName = "분석 실패";
        _isLoading = false;
      });
    }
  }

  Future<File> _loadImage() async {
    return File(widget.image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // AppBar의 높이를 늘립니다
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 20), // Text 위에 20px의 패딩을 추가
            child: Text(
              '업로드 한 사진의 분석 결과예요.',
              style: TextStyle(fontFamily: "myfonts", fontSize: 20),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator()) // 데이터 로딩 중 로딩 인디케이터 표시
            : Column(
                children: [
                  Text(
                    "식사 종류: $mealtype",
                    style: const TextStyle(
                        fontFamily: "myfonts",
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<File>(
                    future: _loadImage(), // 이미지를 비동기로 로드
                    builder:
                        (BuildContext context, AsyncSnapshot<File> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(), // 이미지 로딩 중 로딩 인디케이터
                        );
                      } else if (snapshot.hasError) {
                        return const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 100,
                        ); // 에러 발생 시 에러 아이콘 표시
                      } else {
                        return Center(
                          child: Container(
                            width: 250, // 이미지가 차지할 최대 가로 크기
                            height: 250, // 이미지가 차지할 최대 세로 크기
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey), // 테두리 추가 (원하는 경우)
                            ),
                            child: FittedBox(
                              fit: BoxFit.contain, // 이미지를 영역에 맞게 축소하지만 잘리지 않음
                              child: Image.file(snapshot.data!),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "음식명: $foodName",
                    style: const TextStyle(fontFamily: "myfonts", fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  NutritionBar(
                    label: "칼로리",
                    intake: foodKcal,
                    recommended: recKcal,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFF5722)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  NutritionBar(
                    label: "탄수화물",
                    intake: foodCarb,
                    recommended: recCarb,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90CAF9), Color(0xFF1E88E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  NutritionBar(
                    label: "단백질",
                    intake: foodProt,
                    recommended: recProt,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF176), Color(0xFFFFC107)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  NutritionBar(
                    label: "지방",
                    intake: foodFat,
                    recommended: recFat,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('기록을 취소하실 건가요?'),
                                content: const Text('확인 버튼을 누르면 결과가 기록되지 않아요!'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('취소'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('확인'),
                                    onPressed: () {
                                      context.go('/home/home');
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: const Color.fromRGBO(
                              232, 245, 233, 1), // 눌렸을 때의 색상
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontFamily: "pretendard-regular",
                            fontSize: Sizes.size18,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            // 저장 및 기록 데이터 가져오기
                            final List<Map<String, dynamic>> records =
                                await analyzeRepository
                                    .saveAndFetchMealRecords(context);
                            logger.i(
                                'Record saved successfully: $records'); // 데이터 확인용 로그

                            if (mounted) {
                              // 데이터를 RecordScreen으로 전달하며 네비게이션
                              context.go('/home/record', extra: records);
                            }
                          } catch (e) {
                            logger.e('기록 저장 중 오류 발생: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: const Color.fromARGB(
                              255, 218, 248, 220), // 눌렸을 때의 색상
                        ),
                        child: const Text(
                          '완료',
                          style: TextStyle(
                            fontFamily: "pretendard-regular",
                            fontSize: Sizes.size18,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
