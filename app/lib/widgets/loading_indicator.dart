import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingIndicator extends StatelessWidget {
  final bool isDeep;
  const LoadingIndicator({super.key, required this.isDeep});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: Color(0xFFFF4D6D),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isDeep ? 'Deep analysis in progress...' : 'Checking sources...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            isDeep ? 'This may take a moment' : 'Scanning the web',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 600.ms)
        .then()
        .shimmer(duration: 1200.ms, color: Colors.white10);
  }
}
