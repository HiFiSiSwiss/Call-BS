class Source {
  final String title;
  final String url;
  final String snippet;
  final String? relevance;

  const Source({
    required this.title,
    required this.url,
    required this.snippet,
    this.relevance,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        snippet: json['snippet'] ?? '',
        relevance: json['relevance'],
      );
}

enum Verdict { yes, no, needsContext }

extension VerdictExtension on Verdict {
  static Verdict fromString(String s) {
    switch (s.toLowerCase()) {
      case 'true':
        return Verdict.yes;
      case 'false':
        return Verdict.no;
      default:
        return Verdict.needsContext;
    }
  }

  String get label {
    switch (this) {
      case Verdict.yes:
        return 'TRUE';
      case Verdict.no:
        return 'BS';
      case Verdict.needsContext:
        return 'IT\'S COMPLICATED';
    }
  }

  String get emoji {
    switch (this) {
      case Verdict.yes:
        return '✓';
      case Verdict.no:
        return '✗';
      case Verdict.needsContext:
        return '~';
    }
  }
}

class FactCheckResult {
  final String claim;
  final Verdict verdict;
  final double confidence;
  final String summary;
  final List<Source> sources;
  final String? analysis;
  final List<String>? keyPoints;
  final bool isDeep;

  const FactCheckResult({
    required this.claim,
    required this.verdict,
    required this.confidence,
    required this.summary,
    required this.sources,
    this.analysis,
    this.keyPoints,
    this.isDeep = false,
  });

  factory FactCheckResult.fromJson(Map<String, dynamic> json, {bool deep = false}) {
    return FactCheckResult(
      claim: json['claim'] ?? '',
      verdict: VerdictExtension.fromString(json['verdict'] ?? 'needs_context'),
      confidence: (json['confidence'] as num).toDouble(),
      summary: json['summary'] ?? '',
      sources: (json['sources'] as List? ?? [])
          .map((s) => Source.fromJson(s as Map<String, dynamic>))
          .toList(),
      analysis: json['analysis'],
      keyPoints: (json['key_points'] as List?)?.map((e) => e.toString()).toList(),
      isDeep: deep,
    );
  }
}
