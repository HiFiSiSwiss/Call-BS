import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fact_check_result.dart';

class ResultCard extends StatelessWidget {
  final FactCheckResult result;
  final VoidCallback onDeepCheck;

  const ResultCard({super.key, required this.result, required this.onDeepCheck});

  Color _verdictColor() {
    switch (result.verdict) {
      case Verdict.yes:
        return const Color(0xFF00C896);
      case Verdict.no:
        return const Color(0xFFFF4D6D);
      case Verdict.needsContext:
        return const Color(0xFFFFB74D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVerdictBanner(context),
        const SizedBox(height: 16),
        _buildSummaryCard(context),
        if (result.keyPoints != null && result.keyPoints!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildKeyPoints(context),
        ],
        if (result.analysis != null && result.analysis!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAnalysis(context),
        ],
        if (result.sources.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSources(context),
        ],
        if (!result.isDeep) ...[
          const SizedBox(height: 20),
          _buildDeepCheckButton(context),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerdictBanner(BuildContext context) {
    final color = _verdictColor();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            result.verdict.emoji,
            style: TextStyle(fontSize: 48, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            result.verdict.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 12),
          _ConfidenceBar(confidence: result.confidence, color: color),
          const SizedBox(height: 4),
          Text(
            '${(result.confidence * 100).round()}% confidence',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        result.summary,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildKeyPoints(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY POINTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          ...result.keyPoints!.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _verdictColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAnalysis(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FULL ANALYSIS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            result.analysis!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  height: 1.7,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildSources(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOURCES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 8),
        ...result.sources.asMap().entries.map(
              (e) => _SourceTile(source: e.value, index: e.key + 1),
            ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDeepCheckButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onDeepCheck,
      icon: const Icon(Icons.manage_search_rounded),
      label: const Text(
        'DEEPER ANALYSIS',
        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  final Color color;
  const _ConfidenceBar({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: confidence,
        backgroundColor: Colors.white12,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 6,
      ),
    ).animate().custom(
          duration: 800.ms,
          curve: Curves.easeOut,
          builder: (context, value, child) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence * value,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        );
  }
}

class _SourceTile extends StatelessWidget {
  final Source source;
  final int index;
  const _SourceTile({required this.source, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(source.url);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 10, top: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (source.snippet.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      source.snippet,
                      style: const TextStyle(color: Colors.white30, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (source.relevance != null && source.relevance!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      source.relevance!,
                      style: const TextStyle(
                        color: Color(0xFF7EB8FF),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
