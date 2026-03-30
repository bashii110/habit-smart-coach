// lib/components/ai_coaching_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../firebase auth/ai_service.dart';
import '../utility helpers/consistency_detector.dart';
import '../utility helpers/motivation_service.dart';

class AICoachingCard extends StatefulWidget {
  final List<HabitModel> habits;

  const AICoachingCard({super.key, required this.habits});

  @override
  State<AICoachingCard> createState() => _AICoachingCardState();
}

class _AICoachingCardState extends State<AICoachingCard>
    with SingleTickerProviderStateMixin {
  final AICoachService _aiService = AICoachService();

  CoachingInsight? _insight;
  Map<String, String>? _quote;
  ConsistencyReport? _report;
  bool _loadingAI = false;
  bool _showQuote = false; // toggle between AI insight and quote

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _loadData();
  }

  @override
  void didUpdateWidget(AICoachingCard old) {
    super.didUpdateWidget(old);
    if (old.habits.length != widget.habits.length) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // Load consistency report (instant, rule-based)
    final report = ConsistencyDetector.analyze(widget.habits);
    if (mounted) setState(() => _report = report);

    // Load today's quote
    final quote = await MotivationService.getTodaysQuote();
    if (mounted) setState(() => _quote = quote);

    // Load AI insight (async, may take a moment)
    await _refreshAIInsight();
  }

  Future<void> _refreshAIInsight() async {
    if (_loadingAI) return;
    setState(() => _loadingAI = true);

    final insight = await _aiService.getCoachingInsight(widget.habits);
    if (mounted) {
      setState(() {
        _insight = insight;
        _loadingAI = false;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── AI Coach Card ──────────────────────────────────────
        _buildAICard(isDark),
        const SizedBox(height: 12),

        // ── Consistency Nudge ─────────────────────────────────
        if (_report != null &&
            _report!.status != ConsistencyStatus.new_ &&
            _report!.streaksAtRisk.isNotEmpty)
          _buildStreakWarningCard(isDark),

        // ── Quote Card ────────────────────────────────────────
        if (_quote != null) ...[
          const SizedBox(height: 12),
          _buildQuoteCard(isDark),
        ],
      ],
    );
  }

  Widget _buildAICard(bool isDark) {
    return GestureDetector(
      onTap: _loadingAI ? null : _refreshAIInsight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _getCardGradient(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🧠',
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'AI Coach',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_loadingAI)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _refreshAIInsight,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white.withAlpha(180),
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_loadingAI && _insight == null)
              _buildShimmer()
            else if (_insight != null) ...[
              Text(
                _insight!.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                _insight!.message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 8),
            Text(
              'Tap to refresh insight',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakWarningCard(bool isDark) {
    final topHabit = _report!.streaksAtRisk.first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak at Risk!',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warningColor,
                  ),
                ),
                Text(
                  _report!.nudgeMessage,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💬',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${_quote!['quote']}"',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${_quote!['author']}',
                  style: GoogleFonts.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_shimmerAnim.value - 1).clamp(0.0, 1.0),
                _shimmerAnim.value.clamp(0.0, 1.0),
                (_shimmerAnim.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                Colors.white.withAlpha(20),
                Colors.white.withAlpha(60),
                Colors.white.withAlpha(20),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Getting your personalized insight...',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withAlpha(150),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getCardGradient() {
    if (_insight == null) return AppTheme.primaryGradient;
    switch (_insight!.type) {
      case InsightType.praise:
        return const LinearGradient(
          colors: [Color(0xFF00C851), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case InsightType.warning:
        return const LinearGradient(
          colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case InsightType.tip:
        return const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  Color _getAccentColor() {
    if (_insight == null) return AppTheme.primaryColor;
    switch (_insight!.type) {
      case InsightType.praise:
        return const Color(0xFF00C851);
      case InsightType.warning:
        return const Color(0xFFFF8F00);
      default:
        return AppTheme.primaryColor;
    }
  }
}
