import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/home/providers/token_manager.dart';
import 'package:frontend/features/home/repos/record_repository.dart'; // RecordRepository import

class RecordScreen extends StatefulWidget {
  final bool isLatestFirst;

  const RecordScreen({
    super.key,
    required this.isLatestFirst,
  });

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  var logger = Logger();
  List<Map<String, dynamic>> meals = []; // 화면에 표시할 데이터를 저장할 리스트
  bool _isLoading = true; // 데이터 로딩 상태를 나타내는 변수
  bool _isLatestFirst = true; // 최신순 정렬 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();

    final tokenManager = TokenManager(context: context);
    tokenManager.refreshToken().then((_) {
      _fetchAllRecords(); // 모든 기록 불러오기
    });
  }

  // RecordRepository의 fetchMealRecords API를 호출하는 메서드
  Future<void> _fetchAllRecords() async {
    try {
      logger.i('기록을 가져오는 중입니다...');
      // RecordRepository를 통해 기록을 가져옴
      final mealRecords = await RecordRepository().fetchMealRecords();

      setState(() {
        meals = mealRecords;
        _isLoading = false; // 로딩 상태 해제

        // 시간순으로 정렬 (최신순 or 과거순)
        meals.sort((a, b) {
          final timeA = DateTime.parse(a['time']);
          final timeB = DateTime.parse(b['time']);
          return _isLatestFirst
              ? timeB.compareTo(timeA) // 최신순
              : timeA.compareTo(timeB); // 과거순
        });
      });

      if (meals.isEmpty) {
        logger.i('기록이 없습니다.');
      } else {
        logger.i('모든 기록 불러옴: $meals');
      }
    } catch (e) {
      logger.e('데이터베이스에서 기록을 가져오는 중 오류 발생: $e');
      setState(() {
        _isLoading = false; // 오류 시에도 로딩 상태 해제
      });
    }
  }

  String _getImageForFood(String food) {
    switch (food) {
      case '비빔밥':
        return 'assets/images/food_icons/bibimbap.png';
      case '설렁탕':
        return 'assets/images/food_icons/hot-soup.png';
      case '김치찌개':
        return 'assets/images/food_icons/kimchi.png';
      case '족발':
        return 'assets/images/food_icons/jokbal.png';
      case '삼겹살':
        return 'assets/images/food_icons/samgyeop.png';
      case '카레라이스':
        return 'assets/images/food_icons/curry.png';
      case '우동':
        return 'assets/images/food_icons/udon.png';
      case '돈가스':
        return 'assets/images/food_icons/tonkastu.png';
      case '김밥':
        return 'assets/images/food_icons/gimbap.png';
      case '떡볶이':
        return 'assets/images/food_icons/tteokbokki.png';
      default:
        return 'assets/images/food_icons/rice-bowl.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('RecordScreen - 표시할 meals: $meals');

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 상태 시 표시
          : Column(
              children: [
                // ToggleButtons는 항상 표시되도록 이동
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: ToggleButtons(
                    constraints: const BoxConstraints(
                      minHeight: 30.0, // 적절한 높이 설정
                      minWidth: 70.0, // 버튼의 너비도 설정
                    ),
                    isSelected: [_isLatestFirst, !_isLatestFirst], // 선택 상태
                    onPressed: (index) {
                      setState(() {
                        // 선택된 버튼에 따라 최신순 또는 과거순으로 변경
                        _isLatestFirst = index == 0;
                        // 새 정렬 순서에 따라 데이터를 다시 불러오고 정렬
                        _fetchAllRecords();
                      });
                    },
                    color: Colors.black,
                    selectedColor:
                        const Color.fromARGB(255, 0, 0, 0), // 선택된 텍스트 색상
                    fillColor:
                        const Color.fromARGB(255, 232, 245, 233), // 선택된 버튼의 배경색
                    borderRadius: BorderRadius.circular(10),
                    borderColor: Colors.black,
                    selectedBorderColor: Colors.black, // 선택된 버튼의 테두리 색상
                    borderWidth: 1.2,
                    children: const [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text('최신순',
                            style: TextStyle(
                              fontFamily: "pretendard-regular",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text('과거순',
                            style: TextStyle(
                              fontFamily: "pretendard-regular",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
                // 기록이 있을 때는 기록 목록 표시, 없으면 기록이 없다는 메시지 표시
                Expanded(
                  child: meals.isEmpty
                      ? const Center(
                          child: Text('오늘의 기록을 추가해보세요!')) // 기록이 없을 때 메시지 표시
                      : ListView.builder(
                          itemCount: meals.length,
                          itemBuilder: (context, index) {
                            final meal = meals[index];
                            String formattedTime =
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.parse(meal['time']));
                            String foodImage = _getImageForFood(meal['food']);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.green[50],
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  meal['type'],
                                                  style: const TextStyle(
                                                      fontFamily: "myfonts",
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 8),
                                                Text("음식명 : ${meal['food']}",
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "pretendard-regular",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                                Text(
                                                    "칼로리 : ${meal['calories']} kcal",
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "pretendard-regular",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                                Text(
                                                    "탄수화물 : ${meal['carb']}g / 단백질 : ${meal['protein']}g / 지방 : ${meal['fat']}g",
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "pretendard-regular",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: SizedBox(
                                              width: 64,
                                              height: 64,
                                              child: Image.asset(
                                                foodImage,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "식사 시간: $formattedTime",
                                      style: const TextStyle(
                                        fontFamily: "pretendard-regular",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
