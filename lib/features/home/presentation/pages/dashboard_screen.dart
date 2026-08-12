import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/home/presentation/cubit/home_cubit.dart';
import 'package:truefit_coaches/features/time_tracking/presentation/pages/time_tracking_screen.dart';
import 'package:truefit_coaches/features/attendance/presentation/pages/attendance_screen.dart';
import 'package:truefit_coaches/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:truefit_coaches/features/schedule/presentation/pages/schedule_screen.dart';
import 'package:truefit_coaches/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:truefit_coaches/features/requests/presentation/pages/booking_requests_screen.dart';
import 'package:truefit_coaches/features/home/presentation/pages/main_wrapper.dart';
import '../../../management/domain/entities/management_entities.dart';
import '../../../management/presentation/cubit/management_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, l10n),
              const SizedBox(height: 20),
              _buildClockCard(context, l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.translate('today')),
              const SizedBox(height: 12),
              _buildStatGrid(context, l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                l10n.translate('pt_sessions'),
                actionLabel: l10n.translate('see_all'),
                icon: LucideIcons.zap,
                onAction: () => MainWrapper.of(context)?.setSelectedIndex(1),
              ),
              const SizedBox(height: 12),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded) {
                    final sessions = state.dashboardData['sessions'] as List<dynamic>? ?? [];
                    if (sessions.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(LucideIcons.calendar, size: 40, color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 12),
                              Text(
                                l10n.translate('no_sessions_today'),
                                style: GoogleFonts.barlowCondensed(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: sessions.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildSessionRow(
                          name: s['member_name'] ?? 'Member',
                          time: s['time'] ?? '--:--',
                          duration: (s['duration'] ?? 60).toInt(),
                          location: s['location'] ?? l10n.translate('gym_floor'),
                          startingSoon: _checkStartingSoon(s['time'], s['date']),
                          l10n: l10n,
                        ),
                      )).toList(),
                    );
                  }
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                context,
                l10n.translate('time_tracking'),
                actionLabel: l10n.translate('open_btn'),
                icon: LucideIcons.clock,
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimeTrackingScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildTimeTrackingGrid(context, l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.translate('management'), icon: LucideIcons.briefcase),
              const SizedBox(height: 12),
              _buildQuickActions(context, l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionItem(
              l10n.translate('request_leave'),
              LucideIcons.calendarOff,
              const Color(0xFFF59E0B),
              () => _showLeaveRequestForm(context, l10n),
            ),
          ),
          // Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.05)),
          // Expanded(
          //   child: _buildActionItem(
          //     l10n.translate('salary_deductions'),
          //     LucideIcons.wallet,
          //     const Color(0xFF22C55E),
          //     () {}, // Navigation or modal for coach view
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.barlowCondensed(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveRequestForm(BuildContext context, AppLocalizations l10n) {
    final dateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('request_leave').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),
            _buildModalInput(
              l10n.translate('date'),
              dateCtrl,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildModalInput(l10n.translate('reason'), reasonCtrl, maxLines: 3),
            const SizedBox(height: 32),
            _buildActionBtn(LucideIcons.check, l10n.translate('confirm').toUpperCase(), onTap: () {
              if (dateCtrl.text.isNotEmpty && reasonCtrl.text.isNotEmpty) {
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthAuthenticated) {
                  final coach = authState.coach;
                  context.read<ManagementCubit>().addLeaveRequest(CoachLeave(
                        id: '',
                        coachId: coach['uid'],
                        coachName: coach['name'] ?? 'Coach',
                        coachGender: coach['sex'] ?? 'male',
                        leaveDate: dateCtrl.text,
                        createdAt: DateTime.now(),
                        reason: reasonCtrl.text,
                        status: 'pending',
                      ));
                  Navigator.pop(context);
                }
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModalInput(String label, TextEditingController ctrl, {bool readOnly = false, VoidCallback? onTap, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.barlowCondensed(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = "Coach";
        if (state is AuthAuthenticated) {
          name = state.coach['name'] ?? 'Coach';
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('welcome_back'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.bell, size: 20, color: Colors.white60),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.translate('on_shift'),
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF22C55E),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildClockCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const LiveClock(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: LucideIcons.pause,
                    label: l10n.translate('start_break'),
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimeTrackingScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: LucideIcons.fingerprint,
                    label: l10n.translate('check_in'),
                    color: AppTheme.primaryRed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.barlowCondensed(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label, {String? actionLabel, IconData? icon, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppTheme.primaryRed),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.barlowCondensed(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.barlowCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryRed,
                letterSpacing: 0.6,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        int ptCount = 0;
        if (homeState is HomeLoaded) {
          ptCount = homeState.activePTCount;
        }

        return BlocBuilder<RequestsCubit, RequestsState>(
          builder: (context, requestsState) {
            String requestCount = "0";
            if (requestsState is RequestsLoaded) {
              requestCount = requestsState.requests.length.toString();
            }

            return Row(
              children: [
                _buildStatPill(
                  context,
                  icon: LucideIcons.dumbbell,
                  value: ptCount.toString(),
                  label: l10n.translate('pt_subs'),
                  sub: l10n.translate('active_members'),
                  color: AppTheme.primaryRed,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  context,
                  icon: LucideIcons.calendarDays,
                  value: "2",
                  label: l10n.translate('today_classes'),
                  color: const Color(0xFF60A5FA),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatPill(
                  context,
                  icon: LucideIcons.inbox,
                  value: requestCount,
                  label: l10n.translate('requests'),
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingRequestsScreen()),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    String? sub,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 0.5,
                ),
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _checkStartingSoon(String? time, String? date) {
    if (time == null || date == null) return false;
    try {
      final now = DateTime.now();
      // Parsing "5:00 PM" format
      final format = DateFormat.jm();
      final timeOfDay = format.parse(time);
      final sessionDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      final diff = sessionDateTime.difference(now).inMinutes;
      return diff > 0 && diff <= 30;
    } catch (_) {
      return false;
    }
  }

  Widget _buildSessionRow({
    required String name,
    required String time,
    required int duration,
    required String location,
    bool startingSoon = false,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: startingSoon ? AppTheme.primaryRed.withValues(alpha: 0.07) : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: startingSoon ? AppTheme.primaryRed.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: startingSoon ? AppTheme.primaryRed.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.dumbbell,
              size: 17,
              color: startingSoon ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$time · ${duration}min · $location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          if (startingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.translate('soon'),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryRed,
                ),
              ),
            )
          else
            Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: Colors.white.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTrackingGrid(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildTimeActionButton(
            context,
            icon: LucideIcons.pause,
            label: l10n.translate('start_break'),
            color: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimeTrackingScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTimeActionButton(
            context,
            icon: LucideIcons.play,
            label: l10n.translate('start_pt'),
            color: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimeTrackingScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.35)),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.barlowCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String hh = _now.hour.toString().padLeft(2, '0');
    String mm = _now.minute.toString().padLeft(2, '0');
    String ss = _now.second.toString().padLeft(2, '0');
    
    // Formatting date manually to match React implementation precisely
    final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    
    String weekday = weekdays[_now.weekday - 1];
    String month = months[_now.month - 1];
    String day = _now.day.toString();
    String dateStr = "$weekday, $month $day";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.barlowCondensed(
                fontSize: 84,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -4,
                height: 0.9,
              ),
              children: [
                TextSpan(text: "$hh:$mm"),
                TextSpan(
                  text: ":$ss",
                  style: const TextStyle(
                    color: AppTheme.primaryRed,
                    fontSize: 42,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
