import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../management/domain/entities/management_entities.dart';
import '../cubit/schedule_cubit.dart';
import '../../domain/entities/schedule_entities.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const double _hourHeight = 64.0;
  static const int _startHour = 6;
  static const int _endHour = 28; // Support up to 4 AM next day (24 + 4)
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ScheduleCubit>().init(authState.coach['uid']);
    }
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildWeekNavigator(state),
                _buildWeekStrip(state),
                const Divider(color: Colors.white10, height: 1),
                _buildDayHeader(state, l10n),
                _buildFilterTabs(state, l10n),
                Expanded(
                  child: _buildTimeline(state, l10n),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeekNavigator(ScheduleState state) {
    final monday = _getMonday(state.weekOffset);
    final sunday = monday.add(const Duration(days: 6));
    final rangeText = "${DateFormat('MMM d').format(monday)} – ${DateFormat('MMM d, yyyy').format(sunday)}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.read<ScheduleCubit>().setWeekOffset(state.weekOffset - 1),
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white38),
          ),
          Text(
            rangeText.toUpperCase(),
            style: GoogleFonts.barlowCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white38,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            onPressed: () => context.read<ScheduleCubit>().setWeekOffset(state.weekOffset + 1),
            icon: const Icon(LucideIcons.chevronRight, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip(ScheduleState state) {
    final monday = _getMonday(state.weekOffset);
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: days.map((date) {
          final ds = DateFormat('yyyy-MM-dd').format(date);
          final isSelected = ds == state.selectedDate;
          final isToday = ds == today;
          
          final daySessions = state.sessions.where((s) => s.date == ds).toList();
          final dayClasses = state.classes.where((c) => c.date == ds).toList();
          final dayShift = state.shifts.where((s) => s.date == DateFormat('EEE').format(date)).firstOrNull;

          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<ScheduleCubit>().setSelectedDate(ds),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryRed.withValues(alpha:0.5) : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected || isToday ? AppTheme.primaryRed : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : isToday ? AppTheme.primaryRed : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Mini Shift Bar
                    Container(
                      width: 24,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.06),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: dayShift != null 
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha:0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : null,
                    ),
                    const SizedBox(height: 4),
                    // Activity Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (daySessions.isNotEmpty)
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle)),
                        if (daySessions.isNotEmpty && dayClasses.isNotEmpty) const SizedBox(width: 2),
                        if (dayClasses.isNotEmpty)
                          Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.blue[400], shape: BoxShape.rectangle)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayHeader(ScheduleState state, AppLocalizations l10n) {
    final date = DateTime.parse(state.selectedDate);
    final dayLabel = DateFormat('EEEE, MMM d').format(date);
    
    final daySessions = state.sessions.where((s) => s.date == state.selectedDate).toList();
    final dayClasses = state.classes.where((c) => c.date == state.selectedDate).toList();
    final dayShift = state.shifts.where((s) => s.date == DateFormat('EEE').format(date)).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel.toUpperCase(),
            style: GoogleFonts.barlowCondensed(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (dayShift != null)
                _buildStatPill(LucideIcons.clock, "${dayShift.startTime}–${dayShift.endTime}", Colors.green),
              if (dayShift == null)
                _buildStatPill(LucideIcons.moon, l10n.translate('off_shift').toUpperCase(), Colors.white24),
              const SizedBox(width: 8),
              if (daySessions.isNotEmpty)
                _buildStatPill(null, "${daySessions.length} PT", AppTheme.primaryRed),
              const SizedBox(width: 8),
              if (dayClasses.isNotEmpty)
                _buildStatPill(LucideIcons.users, "${dayClasses.length} ${l10n.translate('today_classes').toUpperCase()}", Colors.blue[400]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(IconData? icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.barlowCondensed(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ScheduleState state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ScheduleFilter.values.map((f) {
          final isSelected = state.filter == f;
          String label = f.name.toUpperCase();
          if (f == ScheduleFilter.all) label = l10n.translate('nav_more').toUpperCase();
          if (f == ScheduleFilter.pt) label = "PT";
          if (f == ScheduleFilter.classes) label = l10n.translate('today_classes').toUpperCase();
          if (f == ScheduleFilter.shifts) label = l10n.translate('work_shifts').toUpperCase();

          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<ScheduleCubit>().setFilter(f),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryRed : const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.primaryRed : Colors.white10),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline(ScheduleState state, AppLocalizations l10n) {
    final ds = state.selectedDate;
    final filteredSessions = state.filter == ScheduleFilter.all || state.filter == ScheduleFilter.pt
        ? state.sessions.where((s) => s.date == ds).toList()
        : <PTSession>[];
    final filteredClasses = state.filter == ScheduleFilter.all || state.filter == ScheduleFilter.classes
        ? state.classes.where((c) => c.date == ds).toList()
        : <GymClass>[];
    final dayShift = state.filter == ScheduleFilter.all || state.filter == ScheduleFilter.shifts
        ? state.shifts.where((s) => s.date == DateFormat('EEE').format(DateTime.parse(ds))).firstOrNull
        : null;

    final allEvents = [
      ...filteredSessions.map((s) => _EventData(
        title: s.memberName,
        time: s.time,
        duration: s.duration,
        type: "PT",
        color: AppTheme.primaryRed,
        location: s.location,
        startingSoon: s.startingSoon,
        onTap: () => _showEventDetails(s, l10n),
      )),
      ...filteredClasses.map((c) => _EventData(
        title: c.name,
        time: c.time,
        duration: int.parse(c.duration),
        type: l10n.translate('today_classes').toUpperCase(),
        color: Colors.blue[400]!,
        location: c.location,
        isClass: true,
        startingSoon: false,
        onTap: () => _showEventDetails(c, l10n),
      )),
    ];

    // Ensure late night sessions are visible
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120), // More bottom padding
        child: Stack(
          children: [
            // Time Grid
            Column(
              children: List.generate(_endHour - _startHour + 1, (i) {
                final hour = _startHour + i;
                return SizedBox(
                  height: _hourHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          _formatHour(hour),
                          style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 1,
                          color: hour % 2 == 0 ? Colors.white.withValues(alpha:0.05) : Colors.white.withValues(alpha:0.02),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            
            // Shift Background
            if (dayShift != null)
              Positioned(
                left: 48,
                right: 0,
                top: _getTopOffset(dayShift.startTime),
                height: _getHeightOffset(dayShift.startTime, dayShift.endTime),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha:0.04),
                    border: const Border(left: BorderSide(color: Colors.green, width: 2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            // Events
            ...allEvents.asMap().entries.map((entry) {
              final e = entry.value;
              
              // Calculate column positioning to avoid overlap
              final eventsAtSameTime = allEvents.where((other) => other.time == e.time).toList();
              final columnIndex = eventsAtSameTime.indexOf(e);
              final totalColumns = eventsAtSameTime.length;

              return _buildEventBlock(
                title: e.title,
                time: e.time,
                duration: e.duration,
                type: e.type,
                color: e.color,
                location: e.location,
                startingSoon: e.startingSoon,
                isClass: e.isClass,
                onTap: e.onTap,
                columnIndex: columnIndex,
                totalColumns: totalColumns,
              );
            }),

            // Current Time Indicator
            if (ds == DateFormat('yyyy-MM-dd').format(DateTime.now()))
              _buildCurrentTimeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBlock({
    required String title,
    required String time,
    required int duration,
    required String type,
    required Color color,
    required String location,
    bool startingSoon = false,
    bool isClass = false,
    required VoidCallback onTap,
    int columnIndex = 0,
    int totalColumns = 1,
  }) {
    final top = _getTopOffset(time);
    final height = (duration / 60.0) * _hourHeight;

    // Use totalColumns to split available width
    // Leave 48px for time labels
    return Positioned(
      left: 48 + (columnIndex * (MediaQuery.of(context).size.width - 64) / totalColumns),
      width: (MediaQuery.of(context).size.width - 64) / totalColumns,
      top: top,
      height: height.clamp(40.0, 500.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 4, bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: startingSoon ? color.withValues(alpha:0.25) : color.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: startingSoon ? color.withValues(alpha:0.6) : color.withValues(alpha:0.3)),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha:0.3), borderRadius: BorderRadius.circular(4)),
                      child: Text(type, style: GoogleFonts.barlowCondensed(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
                    ),
                    if (startingSoon) ...[
                      const SizedBox(width: 8),
                      _PulseDot(color: color),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.barlowCondensed(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (height > 50)
                  Text(
                    "$time · ${location.split('–').first}",
                    style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white38),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    if (now.hour < _startHour || now.hour >= _endHour) return const SizedBox.shrink();
    
    final top = ((now.hour - _startHour) + (now.minute / 60.0)) * _hourHeight;

    return Positioned(
      top: top - 4,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primaryRed, blurRadius: 8)]),
          ),
          Expanded(child: Container(height: 1, color: AppTheme.primaryRed.withValues(alpha:0.7))),
          const SizedBox(width: 4),
          Text(
            DateFormat('h:mm a').format(now),
            style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.primaryRed),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  DateTime _getMonday(int weekOffset) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final monday = now.subtract(Duration(days: dayOfWeek - 1));
    return monday.add(Duration(days: weekOffset * 7));
  }

  String _formatHour(int h) {
    int hour = h % 24;
    if (hour == 0) return "12 AM";
    if (hour == 12) return "12 PM";
    if (hour > 12) return "${hour - 12} PM";
    return "$hour AM";
  }

  double _getTopOffset(String time) {
    if (time.isEmpty) return 0.0;
    
    try {
      // 1. Try standard DateFormat.jm() (e.g. "5:00 PM")
      final format = DateFormat.jm();
      final dateTime = format.parse(time.trim());
      int hour = dateTime.hour;
      
      // If hour is early morning (e.g. 1 AM, 2 AM, 4 AM) and we started at 6 AM
      // treat it as hour 25, 26, 28 for vertical offset
      if (hour < _startHour) {
        hour += 24;
      }
      
      return ((hour - _startHour) + (dateTime.minute / 60.0)) * _hourHeight;
    } catch (_) {
      try {
        // 2. Try manual parsing for "9:00 PM" if jm() fails due to locale/spacing
        final parts = time.toUpperCase().trim().split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        
        if (parts.length > 1) {
          if (parts[1] == 'PM' && hour < 12) hour += 12;
          if (parts[1] == 'AM' && hour == 12) hour = 0;
        }
        
        if (hour < _startHour) {
          hour += 24;
        }
        
        return ((hour - _startHour) + (minute / 60.0)) * _hourHeight;
      } catch (e) {
        // 3. Fallback for "17:00" format
        try {
          final parts = time.split(':').map(int.parse).toList();
          int hour = parts[0];
          int minute = parts.length > 1 ? parts[1] : 0;
          
          if (hour < _startHour) {
            hour += 24;
          }

          return ((hour - _startHour) + (minute / 60.0)) * _hourHeight;
        } catch (_) {
          return 0.0;
        }
      }
    }
  }

  double _getHeightOffset(String start, String end) {
    return _getTopOffset(end) - _getTopOffset(start);
  }

  void _showEventDetails(dynamic event, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EventDetailSheet(event: event, l10n: l10n),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  final dynamic event;
  final AppLocalizations l10n;
  const _EventDetailSheet({required this.event, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isPT = event is PTSession;
    final title = isPT ? (event as PTSession).memberName : (event as GymClass).name;
    final type = isPT ? "PT SESSION" : l10n.translate('today_classes').toUpperCase();
    final color = isPT ? AppTheme.primaryRed : Colors.blue[400]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: GoogleFonts.barlowCondensed(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.barlowCondensed(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildDetailPill(LucideIcons.clock, l10n.translate('time').toUpperCase(), isPT ? (event as PTSession).time : (event as GymClass).time),
              _buildDetailPill(LucideIcons.timer, l10n.translate('duration').toUpperCase(), "${isPT ? (event as PTSession).duration : (event as GymClass).duration} MIN"),
              _buildDetailPill(LucideIcons.mapPin, l10n.translate('location').toUpperCase(), isPT ? (event as PTSession).location : (event as GymClass).location),
              _buildDetailPill(isPT ? LucideIcons.checkCircle : LucideIcons.users, isPT ? l10n.translate('status').toUpperCase() : l10n.translate('instructor').toUpperCase(), isPT ? (event as PTSession).status : (event as GymClass).instructor),
            ],
          ),
          if (!isPT) ...[
            const SizedBox(height: 20),
            _buildCapacityCard(event as GymClass, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppTheme.primaryRed),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.barlowCondensed(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(GymClass cls, AppLocalizations l10n) {
    final progress = cls.enrolled / cls.capacity;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.translate('capacity').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white38)),
              Text("${cls.enrolled} / ${cls.capacity}", style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: progress >= 1 ? AppTheme.primaryRed : Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha:0.06),
            color: progress >= 1 ? AppTheme.primaryRed : Colors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _EventData {
  final String title;
  final String time;
  final int duration;
  final String type;
  final Color color;
  final String location;
  final bool startingSoon;
  final bool isClass;
  final VoidCallback onTap;

  _EventData({
    required this.title,
    required this.time,
    required this.duration,
    required this.type,
    required this.color,
    required this.location,
    required this.startingSoon,
    this.isClass = false,
    required this.onTap,
  });
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
    return FadeTransition(opacity: _controller, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)));
  }
}
