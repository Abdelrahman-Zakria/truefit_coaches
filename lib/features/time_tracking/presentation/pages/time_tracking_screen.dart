import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/time_tracking/presentation/cubit/time_tracking_cubit.dart';
import 'package:truefit_coaches/features/time_tracking/domain/entities/time_entry_entity.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<TimeTrackingCubit>().watchTimeEntries(authState.coach['uid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: BlocBuilder<TimeTrackingCubit, TimeTrackingState>(
          builder: (context, state) {
            if (state is TimeTrackingLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
            }
            if (state is TimeTrackingError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            if (state is TimeTrackingLoaded) {
              return _buildContent(context, state, l10n);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TimeTrackingLoaded state, AppLocalizations l10n) {
    final activeEntry = state.activeBreak ?? state.activeTraining;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(l10n),
          const SizedBox(height: 24),
          if (activeEntry != null) _buildActiveStatus(activeEntry, l10n, key: ValueKey(activeEntry.id)),
          const SizedBox(height: 16),
          _buildActionButtons(context, state, l10n),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('session_history').toUpperCase(),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "${state.timeEntries.length} ${l10n.translate('records').toUpperCase()}",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.timeEntries.isEmpty
                ? _buildEmptyHistory(l10n)
                : ListView.builder(
                    itemCount: state.timeEntries.length,
                    itemBuilder: (context, index) {
                      final entry = state.timeEntries[index];
                      return _buildHistoryItem(entry, l10n);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(LucideIcons.chevronLeft, color: Colors.white38, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.translate('time_tracking').toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStatus(TimeEntryEntity entry, AppLocalizations l10n, {Key? key}) {
    final isBreak = entry.type == TimeEntryType.breakTime;
    final color = isBreak ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6);

    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _PulseDot(color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBreak ? l10n.translate('on_break').toUpperCase() : l10n.translate('personal_training').toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                _ElapsedTimer(startTime: entry.startTime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TimeTrackingLoaded state, AppLocalizations l10n) {
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: state.activeBreak != null ? l10n.translate('end_break') : l10n.translate('start_break'),
            icon: LucideIcons.pause,
            activeColor: const Color(0xFFF59E0B),
            isActive: state.activeBreak != null,
            isDisabled: state.activeTraining != null,
            onTap: () {
              if (state.activeBreak != null) {
                context.read<TimeTrackingCubit>().endTimeEntry(state.activeBreak!.id, state.activeBreak!.startTime);
              } else {
                context.read<TimeTrackingCubit>().startTimeEntry(TimeEntryType.breakTime, authState.coach);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: state.activeTraining != null ? l10n.translate('end_pt') : l10n.translate('start_pt'),
            icon: LucideIcons.play,
            activeColor: const Color(0xFF3B82F6),
            isActive: state.activeTraining != null,
            isDisabled: state.activeBreak != null,
            onTap: () {
              if (state.activeTraining != null) {
                context.read<TimeTrackingCubit>().endTimeEntry(state.activeTraining!.id, state.activeTraining!.startTime);
              } else {
                context.read<TimeTrackingCubit>().startTimeEntry(TimeEntryType.training, authState.coach);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(TimeEntryEntity entry, AppLocalizations l10n) {
    final isBreak = entry.type == TimeEntryType.breakTime;
    final color = isBreak ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isToday = entry.date == today;

    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '—';
      try {
        final dt = DateTime.tryParse(timeStr);
        if (dt != null) return DateFormat.jm().format(dt);
        return timeStr;
      } catch (_) {
        return timeStr;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Icon(LucideIcons.clock, size: 18, color: color)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBreak ? l10n.translate('on_break').toUpperCase() : l10n.translate('personal_training').toUpperCase(),
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                    if (entry.duration != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        "${entry.duration}min",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      isToday ? l10n.translate('today').toUpperCase() : entry.date,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${formatTime(entry.startTime)} → ${formatTime(entry.endTime)}",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${l10n.translate('on_shift').toUpperCase()}: ${entry.shift}",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 48, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Text(
            l10n.translate('no_sessions_today').toUpperCase(),
            style: GoogleFonts.barlowCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.1),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.2) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? activeColor : Colors.white.withValues(alpha: 0.06),
            width: 2,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.3 : 1.0,
          child: Column(
            children: [
              Icon(icon, size: 32, color: isActive ? activeColor : Colors.white24),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isActive ? activeColor : Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)));
  }
}

class _ElapsedTimer extends StatefulWidget {
  final String startTime;
  const _ElapsedTimer({required this.startTime});
  @override
  State<_ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<_ElapsedTimer> {
  late Timer _timer;
  String _elapsed = "00:00";

  @override
  void initState() {
    super.initState();
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
  }

  void _updateTimer() {
    try {
      final now = DateTime.now();
      DateTime startTime;
      
      final parsedIso = DateTime.tryParse(widget.startTime);
      if (parsedIso != null) {
        startTime = parsedIso;
      } else {
        // Fallback for old "hh:mm a" format
        final start = DateFormat('hh:mm a').parse(widget.startTime);
        startTime = DateTime(now.year, now.month, now.day, start.hour, start.minute);
      }
      
      var diff = now.difference(startTime);
      if (diff.isNegative) {
        // Handle case where start was yesterday (late night shift or old format wrap)
        diff = now.difference(startTime.subtract(const Duration(days: 1)));
      }

      final m = diff.inMinutes.toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      
      if (mounted) {
        setState(() {
          _elapsed = "$m:$s";
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _elapsed,
      style: GoogleFonts.barlowCondensed(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
  }
}
