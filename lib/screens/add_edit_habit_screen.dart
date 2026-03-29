// lib/screens/add_edit_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../components/Custom_button.dart';
import '../components/Custom_textfield.dart';
import '../models/habit_model.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class AddEditHabitScreen extends StatefulWidget {
  final HabitModel? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _frequency = 'daily';
  TimeOfDay? _preferredTime;
  String _selectedEmoji = '⭐';
  bool _isLoading = false;

  bool get isEditing => widget.habit != null;

  final List<String> _emojiOptions = [
    '⭐', '💪', '🏃', '📚', '🧘', '💧', '🥗', '😴',
    '🎯', '✍️', '🎵', '🌿', '🧠', '❤️', '🌅', '🏋️',
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    if (isEditing) {
      final h = widget.habit!;
      _titleController.text = h.title;
      _descController.text = h.description;
      _frequency = h.frequency;
      _selectedEmoji = h.iconEmoji ?? '⭐';
      if (h.preferredTime != null) {
        final parts = h.preferredTime!.split(':');
        if (parts.length == 2) {
          _preferredTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _preferredTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final habitProv = context.read<HabitProvider>();

      final timeStr = _preferredTime != null
          ? '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}'
          : null;

      if (isEditing) {
        final updated = widget.habit!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          frequency: _frequency,
          preferredTime: timeStr,
          iconEmoji: _selectedEmoji,
          updatedAt: DateTime.now(),
        );
        await habitProv.updateHabit(updated);
      } else {
        const uuid = Uuid();
        final newHabit = HabitModel(
          id: uuid.v4(),
          userId: auth.user!.uid,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          frequency: _frequency,
          preferredTime: timeStr,
          iconEmoji: _selectedEmoji,
          createdAt: DateTime.now(),
        );
        await habitProv.addHabit(newHabit);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Habit updated! ✅' : 'Habit added! 🎉',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji picker
                _buildSectionLabel(context, 'Icon'),
                const SizedBox(height: 12),
                _buildEmojiPicker(isDark),

                const SizedBox(height: 24),
                _buildSectionLabel(context, 'Title'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _titleController,
                  hint: 'E.g., Morning meditation',
                  prefixIcon: const Icon(Icons.edit_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (val.trim().length < 2) {
                      return 'Title must be at least 2 characters';
                    }
                    if (val.trim().length > 50) {
                      return 'Title must be under 50 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionLabel(context, 'Description (optional)'),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _descController,
                  hint: 'Add a short note about this habit',
                  prefixIcon: const Icon(Icons.notes_outlined),
                  maxLines: 3,
                  validator: (val) {
                    if (val != null && val.length > 200) {
                      return 'Description must be under 200 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _buildSectionLabel(context, 'Frequency'),
                const SizedBox(height: 12),
                _buildFrequencySelector(isDark),

                const SizedBox(height: 20),
                _buildSectionLabel(context, 'Reminder Time'),
                const SizedBox(height: 12),
                _buildTimePicker(isDark),

                const SizedBox(height: 36),

                CustomButton(
                  label: isEditing ? 'Save Changes' : 'Create Habit',
                  onPressed: _save,
                  isLoading: _isLoading,
                  gradient: AppTheme.primaryGradient,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        letterSpacing: 0,
      ),
    );
  }

  Widget _buildEmojiPicker(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _emojiOptions.map((emoji) {
        final isSelected = emoji == _selectedEmoji;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmoji = emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withAlpha(38)
                  : (isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark
                        ? AppTheme.darkSurface
                        : AppTheme.lightTextSecondary.withAlpha(50)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _FrequencyOption(
            label: 'Daily',
            icon: Icons.today_rounded,
            isSelected: _frequency == 'daily',
            onTap: () => setState(() => _frequency = 'daily'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FrequencyOption(
            label: 'Weekly',
            icon: Icons.calendar_view_week_rounded,
            isSelected: _frequency == 'weekly',
            onTap: () => setState(() => _frequency = 'weekly'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(bool isDark) {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _preferredTime != null
                ? AppTheme.primaryColor
                : (isDark
                    ? AppTheme.primaryLight.withAlpha(50)
                    : AppTheme.primaryColor.withAlpha(38)),
            width: _preferredTime != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: _preferredTime != null
                  ? AppTheme.primaryColor
                  : (isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _preferredTime != null
                    ? _preferredTime!.format(context)
                    : 'Set reminder time (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: _preferredTime != null
                      ? (isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.lightTextPrimary)
                      : (isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary),
                ),
              ),
            ),
            if (_preferredTime != null)
              GestureDetector(
                onTap: () => setState(() => _preferredTime = null),
                child: Icon(
                  Icons.close_rounded,
                  color: AppTheme.errorColor.withAlpha(180),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(30)
              : (isDark ? AppTheme.darkCardBg : AppTheme.lightCardBg),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark
                    ? AppTheme.primaryLight.withAlpha(25)
                    : AppTheme.primaryColor.withAlpha(20)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}