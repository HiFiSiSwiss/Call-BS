import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClaimInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool enabled;

  const ClaimInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter a claim to fact-check',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white38,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: '"The Great Wall of China can be seen from space"',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: enabled ? onSubmit : null,
          icon: const Icon(Icons.search_rounded),
          label: const Text('CALL BS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF4D6D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}
