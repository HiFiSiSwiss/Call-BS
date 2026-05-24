import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/fact_check_provider.dart';
import '../widgets/claim_input.dart';
import '../widgets/result_card.dart';
import '../widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(FactCheckProvider provider) {
    final claim = _controller.text.trim();
    if (claim.isEmpty) return;
    provider.checkClaim(claim);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FactCheckProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(provider),
                        const SizedBox(height: 32),
                        ClaimInput(
                          controller: _controller,
                          onSubmit: () => _submit(provider),
                          enabled: !provider.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.state == CheckState.loading ||
                    provider.state == CheckState.deepLoading)
                  SliverFillRemaining(
                    child: LoadingIndicator(
                      isDeep: provider.state == CheckState.deepLoading,
                    ),
                  ),
                if (provider.state == CheckState.error)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildError(provider),
                    ),
                  ),
                if (provider.result != null && provider.state == CheckState.success)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ResultCard(
                        result: provider.result!,
                        onDeepCheck: () => provider.deepCheckClaim(provider.result!.claim),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(FactCheckProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CALL',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1,
                    color: Colors.white,
                  ),
            ),
            Text(
              'BS',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 0.9,
                    color: const Color(0xFFFF4D6D),
                    fontSize: 80,
                  ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
        if (provider.result != null)
          IconButton(
            onPressed: () {
              provider.reset();
              _controller.clear();
            },
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white12,
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildError(FactCheckProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade700.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
          const SizedBox(height: 8),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            provider.error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.reset(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
