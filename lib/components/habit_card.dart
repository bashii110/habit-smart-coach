// lib/components/habit_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatefulWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _animController.forward();
  void _onTapUp(TapUpDetails _) => _animController.reverse();
  void _onTapCancel() => _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habit = widget.habit;
    final isCompleted = habit.isCompletedToday;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onEdit,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dismissible(
          key: Key(habit.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async => true,
          onDismissed: (_) => widget.onDelete(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.successColor.withAlpha(80)
                    : (isDark
                        ? AppTheme.primaryLight.withAlpha(25)
                        : AppTheme.primaryColor.withAlpha(20)),
                width: isCompleted ? 1.5 : 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: (isCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryColor)
                        .withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Emoji icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withAlpha(30)
                        : AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      habit.iconEmoji ?? '⭐',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + streak + insight
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? (isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary)
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Streak badge
                          if (habit.streakCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _streakColor(habit.streakCount)
                                    .withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🔥 ${habit.streakCount}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _streakColor(habit.streakCount),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Frequency chip
                          Text(
                            habit.frequency == 'daily' ? '📅 Daily' : '📆 Weekly',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                          // Preferred time
                          if (habit.preferredTime != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '⏰ ${habit.preferredTime}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Smart insight
                      if (habit.smartTimeSuggestion != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  habit.smartTimeSuggestion!,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.accentDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [AppTheme.successColor, AppTheme.accentColor],
                            )
                          : null,
                      color: isCompleted
                          ? null
                          : (isDark
                              ? AppTheme.darkSurface
                              : AppTheme.primaryColor.withAlpha(15)),
                      borderRadius: BorderRadius.circular(12),
                      border: isCompleted
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppTheme.primaryLight.withAlpha(50)
                                  : AppTheme.primaryColor.withAlpha(50),
                              width: 1.5,
                            ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _streakColor(int streak) {
    if (streak >= 100) return AppTheme.goldColor;
    if (streak >= 30) return AppTheme.silverColor;
    if (streak >= 7) return AppTheme.bronzeColor;
    return AppTheme.warningColor;
  }
}
