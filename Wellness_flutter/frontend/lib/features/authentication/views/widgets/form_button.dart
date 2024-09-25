import 'package:flutter/material.dart';
import 'package:frontend/constants/sizes.dart';

class FormButton extends StatelessWidget {
  final bool disabled;
  final String text;

  const FormButton({
    super.key,
    required this.disabled,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.size5),
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 0, 0), // 밝은 파란색
                    Color.fromARGB(255, 0, 0, 0), // 진한 파란색
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? Colors.grey.shade300 : null,
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
        ),
        duration: const Duration(milliseconds: 500),
        child: AnimatedDefaultTextStyle(
          style: TextStyle(
            color: disabled
                ? Colors.grey.shade400
                : const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w600,
          ),
          duration: const Duration(milliseconds: 500),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
