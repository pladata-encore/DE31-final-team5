import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:http/http.dart' as http;

// import 'dart:convert';

// Todo: 실제 API 서버와 통신하는 코드로 교체 필요
class AuthenticationRepoitory {
  final Map<String, String> _dummyDatabase = {}; // 더미 데이터베이스

  // final String baseUrl = "http://localhost:8000";
  // static const signup = "signup";
  // static const login = "login";

  Future<Map<String, dynamic>> emailSignUp(
      String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_dummyDatabase.containsKey(email)) {
      throw Exception('Email already exists');
    }

    _dummyDatabase[email] = password; // 더미 데이터베이스에 저장

    // 성공적으로 가입했음을 나타내는 더미 응답
    return {
      'status': 'success',
      'email': 'email',
      'message': 'Signup successful',
    };
  }

  /* final response = await http.post(
      Uri.parse('$baseUrl/$signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up');
    }
  }
  */
  Future<Map<String, dynamic>> emailLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_dummyDatabase.containsKey(email) &&
        _dummyDatabase[email] == password) {
      // 로그인 성공
      return {
        'status': 'success',
        'email': email,
        'message': 'Login successful',
      };
    } else {
      // 로그인 실패
      throw Exception('Failed to login');
    }

    /*
    final response = await http.post(
      Uri.parse('$baseUrl/$login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
    */
  }
}

final authRepo = Provider((ref) => AuthenticationRepoitory());
