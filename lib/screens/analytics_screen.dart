// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../utility helpers/data_utils.dart';
import '../components/loading_indicator.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<HabitProvider>().loadAnalytics(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProv, _) {
          if (habitProv.analyticsLoading) {
            return const LoadingIndicator(message: 'Loading analytics...');
          }

          final analytics = habitProv.analytics;
          if (analytics == null) {
            return const Center(child: Text('No data available'));
          }

          final habits = analytics['habits'] as List<HabitModel>;
          final weeklyData =
          analytics['weeklyData'] as Map<String, int>;

          return FadeTransition(
            opacity: _fadeAnim,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildStatsRow(context, analytics, isDark),
                const SizedBox(height: 24),
                _buildWeeklyChart(context, weeklyData, isDark),
                const SizedBox(height: 24),
                _buildInsightsSection(context, habits, isDark),
                const SizedBox(height: 24),
                _buildHabitBreakdown(context, habits, isDark),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(
      BuildContext context,
      Map<String, dynamic> analytics,
      bool isDark,
      ) {
    final total = analytics['totalHabits'] as int;
    final completions = analytics['totalCompletions'] as int;
    final longestStreak = analytics['longestStreak'] as int;
    final rate = analytics['completionRate'] as double;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '🎯',
            label: 'Total Habits',
            value: '$total',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '✅',
            label: 'Completions',
            value: '$completions',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '🔥',
            label: 'Best Streak',
            value: '$longestStreak',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '📈',
            label: 'Weekly Rate',
            value: '${(rate * 100).toInt()}%',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context,
      Map<String, int> weeklyData,
      bool isDark,
      ) {
    final days = AppDateUtils.getLast7Days();
    final maxY = weeklyData.values.isEmpty
        ? 5.0
        : weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < days.length; i++) {
      final dayKey = AppDateUtils.formatDayOfWeek(days[i]);
      final count = weeklyData[dayKey] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              gradient: AppTheme.primaryGradient,
              width: 24,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY > 0 ? maxY + 1 : 5,
                color: isDark
                    ? AppTheme.darkCardBg
                    : AppTheme.primaryColor.withAlpha(13),
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      title: '📅 Weekly Completion',
      isDark: isDark,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY > 0 ? maxY + 1 : 5,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // ✅ Correct parameter for fl_chart 0.66.2
                tooltipBgColor: isDark
                    ? AppTheme.darkCardBg
                    : AppTheme.primaryColor.withAlpha(230),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()} done',
                    GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= days.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        AppDateUtils.formatDayOfWeek(
                            days[value.toInt()]),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark
                    ? AppTheme.darkSurface
                    : AppTheme.primaryColor.withAlpha(20),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(
      BuildContext context,
      List<HabitModel> habits,
      bool isDark,
      ) {
    final insightHabits = habits
        .where((h) => h.smartTimeSuggestion != null)
        .take(3)
        .toList();

    if (insightHabits.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: '💡 Smart Insights',
      isDark: isDark,
      child: Column(
        children: insightHabits.map((habit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      habit.iconEmoji ?? '⭐',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        habit.smartTimeSuggestion!,
                        style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitBreakdown(
      BuildContext context,
      List<HabitModel> habits,
      bool isDark,
      ) {
    if (habits.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: '🏆 Habit Performance',
      isDark: isDark,
      child: Column(
        children: habits.take(5).map((habit) {
          final rate = habit.completionRateThisWeek;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      habit.iconEmoji ?? '⭐',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        habit.title,
                        style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${(rate * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rate >= 0.8
                            ? AppTheme.successColor
                            : rate >= 0.5
                            ? AppTheme.warningColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: isDark
                        ? AppTheme.darkSurface
                        : AppTheme.primaryColor.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      rate >= 0.8
                          ? AppTheme.successColor
                          : rate >= 0.5
                          ? AppTheme.warningColor
                          : AppTheme.errorColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool isDark;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(isDark ? 25 : 20),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withAlpha(isDark ? 25 : 20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}