// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ai_coaching_card.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';
import '../utility helpers/data_utils.dart';
import '../components/habit_card.dart';
import '../components/loading_indicator.dart';
import '../components/empty_state_widget.dart';
import 'add_edit_habit_screen.dart';
import 'analytics_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initHabits();
  }

  void _initHabits() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final habitProv = context.read<HabitProvider>();
      if (auth.user != null) {
        habitProv.listenToHabits(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // ✅ Capture providers BEFORE any await
    final habitProv = context.read<HabitProvider>();
    final authProv = context.read<AuthProvider>();

    habitProv.clearHabits();
    await authProv.logout();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _navigateToAddHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditHabitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildProgressBanner(context),
            _buildTabBar(context, isDark),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
      bottomNavigationBar: _buildBottomNav(context, isDark),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppDateUtils.getGreeting()},',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                    Text(
                      user?.firstName ?? 'there 👋',
                      style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<ThemeProvider>(
                builder: (context, theme, _) => IconButton(
                  icon: Icon(
                    theme.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                  onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
                onPressed: _logout,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBanner(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProv, _) {
        final completed = habitProv.completedTodayCount;
        final total = habitProv.totalHabitsCount;
        final rate = habitProv.todayCompletionRate;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(77),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Progress",
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completed/$total',
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: rate,
                  backgroundColor: Colors.white.withAlpha(64),
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                rate == 1.0
                    ? '🎉 All habits done! Amazing work!'
                    : rate > 0.5
                    ? '💪 More than halfway there!'
                    : total == 0
                    ? 'Add your first habit to get started'
                    : '🚀 Let\'s crush those habits!',
                style: GoogleFonts.inter(
                  color: Colors.white.withAlpha(217),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          _buildTab(context, 0, 'All', isDark),
          const SizedBox(width: 8),
          _buildTab(context, 1, 'Pending', isDark),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, int index, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark
              ? AppTheme.darkCardBg
              : AppTheme.primaryColor.withAlpha(20)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProv, _) {
        if (habitProv.isLoading) {
          return const LoadingIndicator();
        }

        final habits = _selectedIndex == 0
            ? habitProv.habits
            : habitProv.pendingTodayHabits;

        // Only inject the AI card on the "All" tab
        final bool showAICard = _selectedIndex == 0;
        final int aiCardOffset = showAICard ? 1 : 0;

        if (habits.isEmpty) {
          return Column(
            children: [
              if (showAICard)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: AICoachingCard(habits: habitProv.habits),
                ),
              Expanded(
                child: EmptyStateWidget(
                  icon: _selectedIndex == 0 ? '🌱' : '✅',
                  title: _selectedIndex == 0
                      ? 'No habits yet'
                      : 'All done for today!',
                  subtitle: _selectedIndex == 0
                      ? 'Tap + to add your first habit'
                      : 'You\'ve completed all habits for today',
                  action: _selectedIndex == 0
                      ? TextButton(
                    onPressed: _navigateToAddHabit,
                    child: const Text('Add first habit'),
                  )
                      : null,
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          itemCount: habits.length + aiCardOffset,
          itemBuilder: (context, index) {
            // AI card slot — only on "All" tab, only at index 0
            if (showAICard && index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AICoachingCard(habits: habitProv.habits),
              );
            }

            // Correct habit index accounting for the AI card offset
            final habitIndex = index - aiCardOffset;
            final habit = habits[habitIndex];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                habit: habit,
                onToggle: () => _toggleHabit(habit),
                onEdit: () => _editHabit(habit),
                onDelete: () => _deleteHabit(habit),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddHabit,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'New Habit',
        style: GoogleFonts.sora(fontWeight: FontWeight.w600),
      ),
      elevation: 4,
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: true,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Fixed: provider captured before await
  Future<void> _toggleHabit(HabitModel habit) async {
    final habitProv = context.read<HabitProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final completed = await habitProv.toggleHabitCompletion(habit);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            completed
                ? '${habit.title} completed! 🎉'
                : '${habit.title} unmarked',
          ),
          backgroundColor:
          completed ? AppTheme.successColor : AppTheme.warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _editHabit(HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditHabitScreen(habit: habit)),
    );
  }

  // ✅ Fixed: provider and messenger captured before await
  Future<void> _deleteHabit(HabitModel habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete habit?'),
        content: Text(
          'Are you sure you want to delete "${habit.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // ✅ Capture before await
    final habitProv = context.read<HabitProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await habitProv.deleteHabit(habit.id);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Habit deleted'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppTheme.primaryColor
                : (isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? AppTheme.primaryColor
                  : (isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}