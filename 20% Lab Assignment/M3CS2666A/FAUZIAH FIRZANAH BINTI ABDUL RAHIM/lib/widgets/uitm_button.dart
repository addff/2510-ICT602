import 'package:flutter/material.dart';
import '../app_theme.dart';

class UiTMButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const UiTMButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
