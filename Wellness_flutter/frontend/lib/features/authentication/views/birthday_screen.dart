import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/constants/gaps.dart';
import 'package:frontend/constants/sizes.dart';
import 'package:frontend/features/authentication/view_models/signup_view_model.dart';
import 'package:frontend/features/authentication/views/gender_screen.dart';
import 'package:frontend/features/authentication/views/widgets/form_button.dart';
import 'package:frontend/features/authentication/views/widgets/status_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class BirthdayScreen extends ConsumerStatefulWidget {
  static String routeName = "birthday";
  static String routeURL = "/birthday";

  const BirthdayScreen({super.key});

  @override
  ConsumerState<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends ConsumerState<BirthdayScreen> {
  final TextEditingController _birthdayController = TextEditingController();

  DateTime initialDate = DateTime.now();
  String? nickname;
  String? email;

  @override
  void initState() {
    super.initState();
    _setTextFieldDate(initialDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 전달된 데이터를 didChangeDependencies에서 받기
    final extraData =
        (GoRouterState.of(context).extra as Map<String, dynamic>?);

    if (extraData != null) {
      nickname = extraData['nickname'] ?? '';
      email = extraData['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    var logger = Logger();

    // 선택된 생년월일 가져오기
    DateTime selectedDate = initialDate;
    DateTime currentDate = DateTime.now();

    // 생년월일이 현재 날짜에서 1년을 초과하지 않는지 확인
    if (currentDate.difference(selectedDate).inDays <= 365) {
      // 1년 이하인 경우 팝업 표시
      _showBirthdayConfirmationDialog();
    } else {
      // 상태에 생년월일 저장
      final state = ref.read(signUpForm.notifier).state;
      ref.read(signUpForm.notifier).state = {
        ...state,
        "nickname": nickname,
        "email": email,
        "birthday": _birthdayController.text,
      };

      logger.i('${ref.read(signUpForm)}');

      context.goNamed(GenderScreen.routeName);
    }
  }

  void _showBirthdayConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "생년월일 확인",
          ),
          content: const Text(
            "생년월일을 다시 확인해주세요.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _setTextFieldDate(DateTime date) {
    final textDate = date.toString().split(" ").first;
    _birthdayController.value = TextEditingValue(text: textDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && selectedDate != initialDate) {
      setState(() {
        initialDate = selectedDate;
        _setTextFieldDate(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 22.0, top: 20.0),
          child: Text(
            "필수 정보 입력",
            style: TextStyle(
              fontSize: 20,
              fontFamily: "pretendard-regular",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.size10),
            StatusBar(
              currentStep: 1,
              totalSteps: 4,
              width: MediaQuery.of(context).size.width,
              stepCompleteColor: Colors.blue,
              currentStepColor: const Color(0xffdbecff),
              inactiveColor: const Color(0xffbababa),
              lineWidth: 3.5,
            ), // 현재 스텝을 1로 설정
            Gaps.v40,
            const Text(
              "생년월일을 선택해주세요.",
              style: TextStyle(
                fontFamily: "pretendard-regular",
                fontSize: Sizes.size20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gaps.v16,
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Gaps.v28,
            GestureDetector(
              onTap: _birthdayController.text.isNotEmpty ? _onNextTap : null,
              child: FormButton(
                  disabled: _birthdayController.text.isEmpty, text: "Next"),
            ),
          ],
        ),
      ),
    );
  }
}
