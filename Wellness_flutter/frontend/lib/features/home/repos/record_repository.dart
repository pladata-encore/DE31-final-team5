import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecordRepository {
  // 토큰을 SharedPreferences에서 가져오는 메서드
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // 저장된 토큰을 가져옴
  }

  Future<List<Map<String, dynamic>>> fetchMealRecords() async {
    final token = await _getToken(); // 저장된 토큰을 가져옴
    if (token == null) {
      throw Exception('No token found'); // 토큰이 없는 경우 예외 처리
    }

    final response = await http.get(
      Uri.parse(dotenv.env['RECORD_SCREEN_API_URL'] ?? ''), // API URL 변경 필요
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // 저장된 토큰을 헤더에 포함
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Wellness_meal_list에서 필요한 데이터 추출
      final mealList = data['detail']['Wellness_meal_list'] as List<dynamic>;

      // 오늘 날짜 가져오기
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 오늘 날짜에 해당하는 기록만 필터링
      return mealList.map((meal) {
        return {
          'type': meal['meal_type_name'],
          'food': meal['category_name'],
          'calories': meal['food_kcal'],
          'carb': meal['food_car'],
          'protein': meal['food_prot'],
          'fat': meal['food_fat'],
          'time': meal['date'],
        };
      }).where((meal) {
        // meal['time']에서 날짜 부분만 비교
        String mealDate = meal['time'].split('T')[0]; // 'yyyy-MM-dd' 형식으로 날짜 추출
        return mealDate == today; // 오늘 날짜와 비교
      }).toList();
    } else {
      throw Exception('Failed to load meal records');
    }
  }
}
