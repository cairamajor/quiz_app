import 'package:flutter/material.dart';

class HintCard extends StatelessWidget {
  final String hint;
  final bool isLoading;

  const HintCard({super.key, required this.hint, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/icons/hint.png', width: 24, height: 24),
          const SizedBox(width: 10),
          Expanded(
            child: isLoading
                ? const Text(
                    'Getting your hint...',
                    style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
                  )
                : Text(
                    hint,
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}