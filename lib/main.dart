import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CallBsApp());
}

class CallBsApp extends StatelessWidget {
  const CallBsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call-BS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _claimController = TextEditingController();
  bool _isLoading = false;
  bool _isDeepLoading = false;
  ClaimResult? _result;
  String? _errorText;

  String get _backendBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  Future<void> _submitClaim({bool deep = false}) async {
    final claim = _claimController.text.trim();
    if (claim.isEmpty) {
      setState(() {
        _errorText = 'Please type a claim to check.';
      });
      return;
    }

    setState(() {
      _errorText = null;
      if (deep) {
        _isDeepLoading = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final result = await _fetchClaimResult(claim, deep: deep);
      setState(() {
        _result = result;
      });
    } catch (_) {
      setState(() {
        _errorText = 'Unable to fetch results. Check backend and network.';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isDeepLoading = false;
      });
    }
  }

  Future<ClaimResult> _fetchClaimResult(String claim, {bool deep = false}) async {
    final uri = Uri.parse('$_backendBaseUrl/api/check').replace(
      queryParameters: {
        'claim': claim,
        if (deep) 'detail': 'true',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('API returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ClaimResult.fromJson(decoded);
  }

  Color _verdictColor(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'true':
        return Colors.green;
      case 'false':
        return Colors.red;
      default:
        return Colors.amber.shade800;
    }
  }

  Widget _buildResultCard() {
    final result = _result;
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _verdictColor(result.verdict).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      child: Text(
                        result.verdict.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _verdictColor(result.verdict),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${result.confidence}% confidence',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  result.summary,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sources',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...result.sources.map(
                  (source) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• ${source.title} — ${source.url}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (result.deep == null) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Deep dive for context'),
            onPressed: _isDeepLoading ? null : () => _submitClaim(deep: true),
          ),
          if (_isDeepLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
        if (result.deep != null) ...[
          const SizedBox(height: 8),
          const Text(
            'Deep breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...result.deep!.map(
            (item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.heading,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(item.detail),
                    const SizedBox(height: 8),
                    Text(
                      item.source,
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _claimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call-BS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter a claim and get a fast fact-check verdict with sources.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _claimController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Example: "Drinking coffee causes hair loss."',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _submitClaim(deep: false),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(_isLoading ? 'Checking…' : 'Quick check'),
                ),
              ),
              const SizedBox(height: 20),
              if (_result != null) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class ClaimResult {
  final String claim;
  final String verdict;
  final int confidence;
  final String summary;
  final List<Source> sources;
  final List<DeepDetail>? deep;

  ClaimResult({
    required this.claim,
    required this.verdict,
    required this.confidence,
    required this.summary,
    required this.sources,
    this.deep,
  });

  factory ClaimResult.fromJson(Map<String, dynamic> json) {
    return ClaimResult(
      claim: json['claim'] as String,
      verdict: json['verdict'] as String,
      confidence: json['confidence'] as int,
      summary: json['summary'] as String,
      sources: (json['sources'] as List<dynamic>)
          .map((item) => Source.fromJson(item as Map<String, dynamic>))
          .toList(),
      deep: json['deep'] == null
          ? null
          : (json['deep'] as List<dynamic>)
              .map((item) => DeepDetail.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Source {
  final String title;
  final String url;

  Source({required this.title, required this.url});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}

class DeepDetail {
  final String heading;
  final String detail;
  final String source;

  DeepDetail({required this.heading, required this.detail, required this.source});

  factory DeepDetail.fromJson(Map<String, dynamic> json) {
    return DeepDetail(
      heading: json['heading'] as String,
      detail: json['detail'] as String,
      source: json['source'] as String,
    );
  }
}
