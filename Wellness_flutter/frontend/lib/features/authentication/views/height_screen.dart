import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/constants/gaps.dart';
import 'package:frontend/constants/sizes.dart';
import 'package:frontend/features/authentication/view_models/signup_view_model.dart';
import 'package:frontend/features/authentication/views/widgets/form_button.dart';
import 'package:frontend/features/authentication/views/weight_screen.dart';
import 'package:frontend/features/authentication/views/widgets/status_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class HeightScreen extends ConsumerStatefulWidget {
  static String routeName = "height";
  static String routeURL = "/height";

  const HeightScreen({super.key});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  final TextEditingController _integerController =
      TextEditingController(); // 정수 부분
  final TextEditingController _decimalController =
      TextEditingController(); // 소수 부분

  final FocusNode _integerFocusNode = FocusNode(); // 정수 부분 포커스 노드
  final FocusNode _decimalFocusNode = FocusNode(); // 소수 부분 포커스 노드

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context)
          .requestFocus(_integerFocusNode); // 화면이 빌드된 후에 포커스 설정
    });
  }

  @override
  void dispose() {
    _integerController.dispose();
    _decimalController.dispose();
    _integerFocusNode.dispose();
    _decimalFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    final integerPart = _integerController.text;
    final decimalPart = _decimalController.text;

    if (integerPart.isNotEmpty && decimalPart.isNotEmpty) {
      final double? height = double.tryParse("$integerPart.$decimalPart");

      if (height != null && height >= 100.0 && height <= 250.0) {
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "100 - 250 사이의 값을 입력해주세요.";
        });
      }
    } else {
      setState(() {
        _errorMessage = "유효하지 않는 값입니다.";
      });
    }
  }

  void _onNextTap() {
    final height = "${_integerController.text}.${_decimalController.text}";
    var logger = Logger();

    ref.read(signUpForm.notifier).state = {
      ...ref.read(signUpForm.notifier).state,
      "height": height,
    };

    logger.i('${ref.read(signUpForm)}');

    context.goNamed(WeightScreen.routeName);
  }

  void _onIntegerChanged(String value) {
    if (value.length == 3) {
      _decimalFocusNode.requestFocus(); // 즉시 포커스 이동
    }
    _validateInput();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이 가져오기
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0), // 상단에 20px 패딩 추가
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.goNamed("gender");
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0), // 아이콘과 텍스트 사이의 간격
                child: Text(
                  "필수 정보 입력",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "pretendard-regular",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView로 감싸서 스크롤 가능하게 함
        padding: EdgeInsets.only(
          left: Sizes.size36,
          right: Sizes.size36,
          bottom: bottomPadding, // 키보드 높이만큼 패딩 추가
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.size10),
            StatusBar(
              currentStep: 3,
              totalSteps: 4,
              width: MediaQuery.of(context).size.width,
              stepCompleteColor: Colors.blue,
              currentStepColor: const Color(0xffdbecff),
              inactiveColor: const Color(0xffbababa),
              lineWidth: 3.5,
            ), // 현재 스텝을 3로 설정
            Gaps.v40,
            const Text(
              "키(cm)를 입력해주세요.",
              style: TextStyle(
                fontFamily: "pretendard-regular",
                fontSize: Sizes.size20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gaps.v16,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 정수 부분 입력 필드
                SizedBox(
                  width: 80, // 가로 길이 조절
                  child: TextField(
                    controller: _integerController,
                    focusNode: _integerFocusNode, // 정수 포커스 노드 설정
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3), // 최대 3자리까지 입력 가능
                    ],
                    decoration: InputDecoration(
                      hintText: "000", // 텍스트 필드에 표시되는 힌트
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "pretendard-regular",
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    onChanged: _onIntegerChanged, // 값 변경 시 포커스 체크
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  ".",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 10),
                // 소수 부분 입력 필드
                SizedBox(
                  width: 60, // 가로 길이 조절
                  child: TextField(
                    controller: _decimalController,
                    focusNode: _decimalFocusNode, // 소수 포커스 노드 설정
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1), // 최대 1자리까지 입력 가능
                    ],
                    decoration: InputDecoration(
                      hintText: "0", // 텍스트 필드에 표시되는 힌트
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "pretendard-regular",
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      _validateInput();
                    },
                  ),
                ),
              ],
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: Sizes.size14,
                  ),
                ),
              ),
            Gaps.v28,
            GestureDetector(
              onTap: _integerController.text.isNotEmpty &&
                      _decimalController.text.isNotEmpty &&
                      _errorMessage == null
                  ? _onNextTap
                  : null,
              child: FormButton(
                disabled: _integerController.text.isEmpty ||
                    _decimalController.text.isEmpty ||
                    _errorMessage != null,
                text: "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
