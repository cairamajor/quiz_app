import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final bool answered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.answered,
    required this.isCorrect,
    required this.isSelected,
    this.onTap,
  });

  Color get _backgroundColor {
    if (!answered) return Colors.indigo.shade50;
    if (isCorrect) return Colors.green.shade400;
    if (isSelected) return Colors.red.shade400;
    return Colors.grey.shade200;
  }

  Color get _textColor {
    if (!answered) return Colors.indigo.shade900;
    if (isCorrect || isSelected) return Colors.white;
    return Colors.grey.shade600;
  }

  Widget? get _trailingIcon {
    if (!answered) return null;
    if (isCorrect) {
      return Image.asset('assets/icons/correct.png', width: 22, height: 22);
    }
    if (isSelected) {
      return Image.asset('assets/icons/wrong.png', width: 22, height: 22);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: answered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: answered && isCorrect
                  ? Colors.green
                  : answered && isSelected
                      ? Colors.red
                      : Colors.indigo.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_trailingIcon != null) _trailingIcon!,
            ],
          ),
        ),
      ),
    );
  }
}