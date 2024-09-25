import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class AnalyzeRepository {
  final String apiUrl = dotenv.env['ANALYZE_API_URL'] ?? ''; // 분석 화면 API
  final String saveUrl = dotenv.env['HISTORY_API_URL'] ?? ''; // 기록 화면 API

  final Logger _logger = Logger(); // Logger 인스턴스 생성

  Map<String, dynamic>? analysisData;

  // 토큰을 SharedPreferences에서 가져오는 메서드
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // 저장된 토큰을 가져옴
  }

  // 첫 번째 API에 이미지 업로드 및 데이터 가져오기(분석화면)
  Future<Map<String, dynamic>> uploadImageAndFetchData(
      File image, BuildContext context) async {
    final token = await _getToken(); // 저장된 토큰을 가져옴
    if (token == null) {
      throw Exception('No token found'); // 토큰이 없을 때 예외 처리
    }

    // 파일 확장자 확인
    String fileExtension = path.extension(image.path).toLowerCase();
    if (!(fileExtension == '.jpg' ||
        fileExtension == '.jpeg' ||
        fileExtension == '.png')) {
      // 확장자가 맞지 않으면 팝업 띄우기
      _showInvalidFileExtensionDialog(context);
      return Future.error('Invalid file extension');
    }

    final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..files.add(await http.MultipartFile.fromPath(
        'file', // API에서 기대하는 필드 이름
        image.path,
        contentType: MediaType.parse(mimeType),
      ))
      ..headers['Authorization'] = 'Bearer $token'; // 저장된 토큰을 헤더에 추가

    try {
      _logger.i('이미지 업로드 시작');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logger.i('이미지 업로드 응답 코드: ${response.statusCode} / 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 응답 데이터를 파싱합니다.
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // 필요한 데이터 저장
        analysisData = {
          'date': data['detail']['wellness_image_info']['date'],
          'meal_type_id': data['detail']['wellness_image_info']['meal_type_id'],
          'category_id': data['detail']['wellness_image_info']['category_id'],
          'image_url': data['detail']['wellness_image_info']['image_url'],
        };

        _logger.i(
            'analysisData 설정됨: ${analysisData.toString()}'); // analysisData 설정 확인
        return data;
      } else {
        _logger
            .e('이미지 업로드 실패: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception(
            '이미지 업로드 실패: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('이미지 업로드 중 예외 발생: $e');
      throw Exception('이미지 업로드 중 예외 발생: $e');
    }
  }

// 잘못된 파일 확장자일 때 팝업 띄우기
  void _showInvalidFileExtensionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '파일 업로드 실패',
          ),
          content: const Text(
            '파일 형식을 확인해주세요. \nJPG, JPEG 또는 PNG 형식의 파일만 업로드할 수 있어요.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home/home');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

// 두 번째 API로 데이터 전송 및 기록 가져오기(기록화면)
  Future<List<Map<String, dynamic>>> saveAndFetchMealRecords(
      BuildContext context) async {
    if (analysisData == null) {
      _logger.w('분석 데이터가 없습니다.');
      throw Exception('분석 데이터가 없습니다.');
    }

    final token = await _getToken(); // 저장된 토큰을 가져옴
    if (token == null) {
      throw Exception('No token found'); // 토큰이 없을 때 예외 처리
    }

    _logger.i('데이터 전송 시작: ${analysisData.toString()}');

    // 날짜 형식 변환
    String originalDate = analysisData!['date'];
    // 파싱 가능한 형식으로 변환
    DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(originalDate);
    // 서버에서 기대하는 형식으로 변환
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

    // 현재 날짜와 분석 데이터의 날짜를 비교
    DateTime today = DateTime.now();
    String todayDateString =
        DateFormat('yyyy-MM-dd').format(today); // 오늘 날짜 문자열로 변환
    String analysisDateString =
        DateFormat('yyyy-MM-dd').format(parsedDate); // 분석 날짜 문자열로 변환

    // 날짜가 다르면 팝업 띄우기
    if (todayDateString != analysisDateString) {
      _showDateErrorDialog(context); // 팝업 함수 호출
      return Future.error('사진은 오늘 날짜여야 합니다.');
    }

    final response = await http.post(
      Uri.parse(saveUrl), // 두 번째 API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': formattedDate, // 변환된 날짜를 사용
        'meal_type_id': analysisData!['meal_type_id'],
        'category_id': analysisData!['category_id'],
        'image_url': analysisData!['image_url'],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final mealList = data['detail']['Wellness_meal_list'] as List<dynamic>;

      _logger.i('기록 저장 및 가져오기 성공: ${mealList.toString()}');

      final records = mealList.map((meal) {
        return {
          'type': meal['meal_type_name'],
          'food': meal['category_name'],
          'calories': meal['food_kcal'],
          'carb': meal['food_car'],
          'protein': meal['food_prot'],
          'fat': meal['food_fat'],
          'time': meal['date'],
        };
      }).toList();

      _logger.i('반환된 기록: $records');

      return records;
    } else {
      _logger.e(
          '기록 저장 및 가져오기 실패: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('기록 저장 및 가져오기 실패');
    }
  }

// 날짜가 오늘이 아닐 때 팝업을 띄우는 함수
  void _showDateErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '오늘 드신 음식인가요?',
          ),
          content: const Text(
            '아직은 오늘 먹은 음식만 업로드할 수 있어요.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home/home');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 서버에서 기존 기록만 가져오기
  Future<List<Map<String, dynamic>>> fetchPreviousRecords() async {
    final token = await _getToken(); // 저장된 토큰을 가져옴
    if (token == null) {
      throw Exception('No token found'); // 토큰이 없을 때 예외 처리
    }

    // 날짜 형식 변환
    String originalDate = analysisData!['date'];
    // 파싱 가능한 형식으로 변환
    DateTime parsedDate = DateFormat('yyyy:MM:dd HH:mm:ss').parse(originalDate);
    // 서버에서 기대하는 형식으로 변환
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

    try {
      final response = await http.post(
        Uri.parse(saveUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': formattedDate, // 변환된 날짜를 사용
          'meal_type_id': analysisData!['meal_type_id'],
          'category_id': analysisData!['category_id'],
          'image_url': analysisData!['image_url'],
        }), // body에 필요한 데이터 추가 가능
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final mealList = data['detail']['Wellness_meal_list'] as List<dynamic>;

        _logger.i('기존 기록 가져오기 성공: ${mealList.toString()}');

        final records = mealList.map((meal) {
          return {
            'type': meal['meal_type_name'],
            'food': meal['category_name'],
            'calories': meal['food_kcal'],
            'carb': meal['food_car'],
            'protein': meal['food_prot'],
            'fat': meal['food_fat'],
            'time': meal['date'],
          };
        }).toList();

        return records;
      } else {
        _logger
            .e('기록 가져오기 실패: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('기록 가져오기 실패');
      }
    } catch (e) {
      _logger.e('기록 가져오기 중 예외 발생: $e');
      throw Exception('기록 가져오기 중 예외 발생: $e');
    }
  }
}
