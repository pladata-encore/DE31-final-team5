import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

class NutritionBar extends StatefulWidget {
  final String label; // 영양소 이름
  final int intake; // 섭취량
  final int recommended; // 권장 섭취량
  final Gradient gradient; // 진행 바의 그라데이션 색상

  const NutritionBar({
    super.key,
    required this.label,
    required this.intake,
    required this.recommended,
    required this.gradient,
  });

  @override
  _NutritionBarState createState() => _NutritionBarState();
}

class _NutritionBarState extends State<NutritionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 권장량을 넘어도 그대로 비율 계산
    double percentage = widget.intake / widget.recommended;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, microseconds: 30),
    );

    _animation = Tween<double>(begin: 0, end: percentage).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨과 섭취/권장 텍스트를 한 줄로 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                    fontFamily: "pretendart-regular",
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              // 섭취 / 권장 (비율%) 텍스트 표시
              Text(
                "${widget.intake.toStringAsFixed(0)} / ${widget.recommended.toStringAsFixed(0)} g (${(_animation.value * 100).toStringAsFixed(0)}%)",
                style: const TextStyle(
                  fontFamily: "pretendart-regular",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 그라데이션이 적용된 바
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: double.infinity, // 전체 너비
                    height: 15, // 바 높이
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 202, 202, 202), // 배경 색상
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    // 애니메이션 값이 1을 넘어도 제대로 표시되도록 수정
                    width: (_animation.value <= 1.0 ? _animation.value : 1.0) *
                        constraints.maxWidth,
                    height: 15, // 바 높이
                    decoration: BoxDecoration(
                      gradient: widget.gradient, // 그라데이션 적용
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
