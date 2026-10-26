import 'package:flutter/material.dart';

/// Keep the app's existing flag artwork alongside readable language names.
class LanguageLabel extends StatelessWidget {
  final String language;
  final TextStyle? style;

  const LanguageLabel(this.language, {super.key, this.style});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.asset(
          'assets/flag_of_$language.png',
          width: 24,
          height: 18,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 24),
        ),
      ),
      const SizedBox(width: 8),
      Text(language, style: style),
    ],
  );
}
