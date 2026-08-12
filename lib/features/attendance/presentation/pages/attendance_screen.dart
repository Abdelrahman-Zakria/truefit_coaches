import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:truefit_coaches/features/attendance/domain/entities/attendance_entry_entity.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _holding = false;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (_controller.value >= 1.0 && !_confirmed) {
          _onConfirm();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<AttendanceCubit>().load(authState.coach['uid']);
      }
    });
  }

  void _onConfirm() {
    setState(() {
      _confirmed = true;
      _holding = false;
    });

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceCubit>().checkIn(authState.coach['uid']);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _confirmed = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white38),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AttendanceCubit, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppTheme.primaryRed),
              );
            }
          },
          builder: (context, state) {
            final history = state is AttendanceLoaded ? state.history : <AttendanceEntryEntity>[];
            final current = state is AttendanceLoaded ? state.current : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('nav_attendance').toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        _buildFingerprintScanner(current),
                        const SizedBox(height: 24),
                        _buildStatusText(current, l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    l10n.translate('attendance_history').toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: history.isEmpty 
                      ? Center(child: Text(l10n.translate('no_history'), style: const TextStyle(color: Colors.white24)))
                      : ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) => _buildHistoryItem(history[index], l10n),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFingerprintScanner(AttendanceEntryEntity? current) {
    bool checkedIn = current != null;

    return GestureDetector(
      onPanDown: (_) {
        if (!checkedIn) {
          setState(() => _holding = true);
          _controller.forward();
        } else {
          context.read<AttendanceCubit>().checkOut(current.id);
        }
      },
      onPanEnd: (_) {
        if (!_confirmed) {
          setState(() => _holding = false);
          _controller.reverse();
        }
      },
      onPanCancel: () {
        if (!_confirmed) {
          setState(() => _holding = false);
          _controller.reverse();
        }
      },
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(180, 180),
              painter: _ProgressPainter(
                progress: 1.0,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(180, 180),
                  painter: _ProgressPainter(
                    progress: checkedIn ? 1.0 : _controller.value,
                    color: checkedIn ? const Color(0xFF22C55E) : AppTheme.primaryRed,
                  ),
                );
              },
            ),
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                _confirmed || checkedIn
                    ? LucideIcons.checkCircle
                    : LucideIcons.fingerprint,
                size: 56,
                color: checkedIn
                    ? const Color(0xFF22C55E)
                    : _holding
                        ? AppTheme.primaryRed
                        : Colors.white.withValues(alpha: 0.3),
                shadows: [
                  if (_holding || checkedIn)
                    Shadow(
                      color: checkedIn ? const Color(0xFF22C55E) : AppTheme.primaryRed,
                      blurRadius: 12,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText(AttendanceEntryEntity? current, AppLocalizations l10n) {
    if (current != null) {
      final timeStr = "${current.timestampIn.hour}:${current.timestampIn.minute.toString().padLeft(2, '0')}";
      return Column(
        children: [
          Text(
            "✓ ${l10n.translate('confirmed_text')}",
            style: GoogleFonts.barlowCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${l10n.translate('live_time')} $timeStr",
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('check_out'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          _holding ? "${l10n.translate('scanning').toUpperCase()}... ${(_controller.value * 100).toInt()}%" : l10n.translate('hold_to_checkin').toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.translate('hold_for_2s'),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(AttendanceEntryEntity entry, AppLocalizations l10n) {
    final dateStr = "${entry.timestampIn.day}/${entry.timestampIn.month}/${entry.timestampIn.year}";
    final timeInStr = "${entry.timestampIn.hour}:${entry.timestampIn.minute.toString().padLeft(2, '0')}";
    String? timeOutStr;
    String? duration;

    if (entry.timestampOut != null) {
      timeOutStr = "${entry.timestampOut!.hour}:${entry.timestampOut!.minute.toString().padLeft(2, '0')}";
      final diff = entry.timestampOut!.difference(entry.timestampIn);
      duration = "${diff.inHours}h ${diff.inMinutes % 60}m";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 10, color: Colors.white38),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 200,
                        child: Text(
                          entry.locationName,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: entry.status == 'active'
                      ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.status == 'active' ? l10n.translate('active').toUpperCase() : duration ?? "",
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: entry.status == 'active' ? const Color(0xFF22C55E) : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimeBadge("${l10n.translate('time_in').toUpperCase()} $timeInStr", const Color(0xFF22C55E)),
              if (timeOutStr != null) ...[
                const SizedBox(width: 16),
                _buildTimeBadge("${l10n.translate('time_out').toUpperCase()} $timeOutStr", Colors.white38),
              ],
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTimeBadge(String text, Color color) {
    return Row(
      children: [
        Icon(LucideIcons.clock, size: 12, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
