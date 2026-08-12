import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/intl/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/management_cubit.dart';
import '../../domain/entities/management_entities.dart';
import '../../data/models/management_models.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    context.read<ManagementCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ManagementCubit, ManagementState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(l10n),
                _buildTabSelector(state.currentTab, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTabContent(state, l10n),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('management').toUpperCase(),
            style: const TextStyle(
              fontFamily: 'BarlowCondensed',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            l10n.translate('head_coach').toUpperCase(),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10,
              color: Colors.white24,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(ManagementTab currentTab, AppLocalizations l10n) {
    final List<Map<String, dynamic>> correctedTabs = [
      {'key': ManagementTab.shifts, 'icon': LucideIcons.calendar, 'label': l10n.translate('work_shifts').toUpperCase()},
      {'key': ManagementTab.inbody, 'icon': LucideIcons.dumbbell, 'label': l10n.translate('inbody').toUpperCase()},
      {'key': ManagementTab.classes, 'icon': LucideIcons.layoutGrid, 'label': l10n.translate('classes').toUpperCase()},
      {'key': ManagementTab.salary, 'icon': LucideIcons.dollarSign, 'label': l10n.translate('salary_deductions').toUpperCase()},
      {'key': ManagementTab.leaves, 'icon': LucideIcons.calendarX, 'label': l10n.translate('leave_requests').toUpperCase()},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: correctedTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = correctedTabs[index];
          final isSelected = currentTab == tab['key'];
          return GestureDetector(
            onTap: () => context.read<ManagementCubit>().setTab(tab['key']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha:0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(tab['icon'], size: 14, color: isSelected ? Colors.white : Colors.white38),
                  const SizedBox(width: 8),
                  Text(
                    tab['label'],
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : Colors.white38,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(ManagementState state, AppLocalizations l10n) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
        
        final headCoachSex = authState.coach['sex'] ?? 'male';
        final filteredCoaches = state.allCoaches.where((c) => c['sex'] == headCoachSex).toList();

        switch (state.currentTab) {
          case ManagementTab.shifts:
            return _buildShiftsTab(state, filteredCoaches, l10n);
          case ManagementTab.inbody:
            return _buildInBodyTab(state, l10n);
          case ManagementTab.classes:
            return _buildClassesTab(state);
          case ManagementTab.salary:
            return _buildSalaryTab(state, filteredCoaches, l10n);
          case ManagementTab.leaves:
            return _buildLeavesTab(state, l10n, authState.coach['uid'] ?? '');
        }
      },
    );
  }

  Widget _buildLeavesTab(ManagementState state, AppLocalizations l10n, String headCoachId) {
    if (state.leaves.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(LucideIcons.calendarCheck, size: 48, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Text(l10n.translate('no_requests').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: state.leaves.map((leave) => _buildLeaveCard(leave, l10n, headCoachId)).toList(),
      ),
    );
  }

  Widget _buildLeaveCard(CoachLeave leave, AppLocalizations l10n, String headCoachId) {
    final bool isPending = leave.status == 'pending';
    final Color statusColor = leave.status == 'approved' ? Colors.green : leave.status == 'rejected' ? AppTheme.primaryRed : Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                  Text(leave.coachName, style: GoogleFonts.barlowCondensed(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(leave.leaveDate, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  leave.status.toUpperCase(),
                  style: GoogleFonts.barlowCondensed(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(leave.reason, style: const TextStyle(fontSize: 13, color: Colors.white60)),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    label: l10n.translate('reject'),
                    color: AppTheme.primaryRed,
                    onTap: () => context.read<ManagementCubit>().updateLeaveStatus(leave.id, 'rejected', headCoachId),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    label: l10n.translate('accept'),
                    color: Colors.green,
                    onTap: () => context.read<ManagementCubit>().updateLeaveStatus(leave.id, 'approved', headCoachId),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBtn({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.barlowCondensed(fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftsTab(ManagementState state, List<Map<String, dynamic>> coaches, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 80),
              ..._days.map((d) => SizedBox(
                width: 70,
                child: Center(
                  child: Text(
                    d.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white24,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          ...coaches.map((coach) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            (coach['name'] ?? 'C').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'BarlowCondensed',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coach['name'] ?? 'Coach',
                          style: const TextStyle(
                            fontFamily: 'BarlowCondensed',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._days.map((day) {
                  final shift = state.shifts.firstWhere(
                    (s) => s.coachId == coach['uid'] && s.day == day,
                    orElse: () => CoachShiftModel(id: '', coachId: coach['uid'] ?? '', day: day, startTime: '', endTime: '', isOff: true),
                  );
                  return _buildShiftCell(shift, l10n);
                }),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildShiftCell(CoachShift shift, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showShiftEditor(shift, l10n),
      child: Container(
        width: 66,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: shift.isOff ? Colors.white.withValues(alpha:0.03) : AppTheme.primaryRed.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: shift.isOff ? Colors.white.withValues(alpha:0.05) : AppTheme.primaryRed.withValues(alpha:0.25),
          ),
        ),
        child: Center(
          child: shift.isOff
              ? Text(l10n.translate('off_shift').toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white24))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(shift.startTime, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                    Text(shift.endTime, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryRed.withValues(alpha:0.6))),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInBodyTab(ManagementState state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildAddButton(l10n.translate('add_slot').toUpperCase(), LucideIcons.plus, () => _showInBodySlotEditor(l10n)),
          const SizedBox(height: 16),
          ...state.inBodySlots.map((slot) => _buildInBodyCard(slot, l10n)),
        ],
      ),
    );
  }

  Widget _buildInBodyCard(InBodySlot slot, AppLocalizations l10n) {
    final isBooked = slot.memberName != null && slot.memberName!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${slot.date} · ${slot.time}",
                style: GoogleFonts.barlowCondensed(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isBooked ? Colors.green.withValues(alpha:0.12) : Colors.amber.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isBooked ? l10n.translate('confirmed_text').toUpperCase() : l10n.translate('open_btn').toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isBooked ? Colors.green : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.user, size: 12, color: AppTheme.primaryRed.withValues(alpha:0.6)),
              const SizedBox(width: 8),
              Text(
                "${l10n.translate('instructor')}: ${slot.supervisorName}",
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
          if (isBooked) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.users, size: 12, color: Colors.white24),
                const SizedBox(width: 8),
                Text(
                  "${l10n.translate('member')}: ${slot.memberName}",
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassesTab(ManagementState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ...state.classes.map((cls) => _buildClassCard(cls)),
        ],
      ),
    );
  }

  Widget _buildClassCard(GymClass cls) {
    final progress = cls.enrolled / cls.capacity;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.name, style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text("${cls.date} · ${cls.time} · ${cls.location}", style: const TextStyle(fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ),
              Switch(
                value: cls.isOpen,
                onChanged: (val) => context.read<ManagementCubit>().toggleClass(cls.id, val),
                activeThumbColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.08), borderRadius: BorderRadius.circular(3)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progress >= 1 ? AppTheme.primaryRed : Colors.green,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text("${cls.enrolled}/${cls.capacity}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 12),
          Text("${cls.instructor} · ${cls.duration}min", style: const TextStyle(fontSize: 12, color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildSalaryTab(ManagementState state, List<Map<String, dynamic>> coaches, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildAddButton(l10n.translate('add_deduction').toUpperCase(), LucideIcons.plus, () => _showDeductionEditor(l10n)),
          const SizedBox(height: 16),
          ...coaches.map((coach) {
            final coachDeds = state.deductions.where((d) => d.coachId == coach['uid']).toList();
            final totalDed = coachDeds.fold<double>(0, (sum, d) => sum + d.amount);
            final baseSalary = (coach['baseSalary'] ?? 0).toDouble();
            final net = baseSalary - totalDed;
            
            final coachData = {
              'id': coach['uid'],
              'name': coach['name'] ?? 'Coach',
              'avatar': (coach['name'] ?? 'C').substring(0, 1).toUpperCase(),
              'specialty': (coach['specialty'] is Map) 
                  ? (coach['specialty']['en'] ?? 'Trainer') 
                  : (coach['specialty'] ?? 'Trainer'),
              'baseSalary': baseSalary.toInt(),
            };

            return _buildCoachSalaryCard(coachData, coachDeds, totalDed, net, l10n);
          }),
        ],
      ),
    );
  }

  Widget _buildCoachSalaryCard(Map<String, dynamic> coach, List<Deduction> deds, double totalDed, double net, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.15), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(coach['avatar'], style: const TextStyle(fontFamily: 'BarlowCondensed', fontWeight: FontWeight.w900, color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coach['name'], style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(coach['specialty'], style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: Colors.white24)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSalaryStat(l10n.translate('base_salary'), "EGP ${coach['baseSalary']}", Colors.white70),
              const SizedBox(width: 8),
              _buildSalaryStat(l10n.translate('deductions'), "-EGP ${totalDed.toInt()}", AppTheme.primaryRed),
              const SizedBox(width: 8),
              _buildSalaryStat("Net", "EGP ${net.toInt()}", Colors.green),
            ],
          ),
          if (deds.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...deds.map((d) => Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha:0.06), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d.reason, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  Text("-${d.amount.toInt()}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSalaryStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 9, color: Colors.white24, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, fontWeight: FontWeight.w900, color: valueColor))),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  void _showShiftEditor(CoachShift shift, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: l10n.translate('assign_shift').toUpperCase(),
        heightFactor: 0.55,
        child: _ShiftForm(shift: shift),
      ),
    );
  }

  void _showInBodySlotEditor(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: l10n.translate('add_slot').toUpperCase(),
        heightFactor: 0.7,
        child: const _InBodyForm(),
      ),
    );
  }

  void _showDeductionEditor(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: l10n.translate('add_deduction').toUpperCase(),
        heightFactor: 0.65,
        child: const _DeductionForm(),
      ),
    );
  }
}

class _ManagementBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const _ManagementBottomSheet({required this.title, required this.child, required this.heightFactor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ShiftForm extends StatefulWidget {
  final CoachShift shift;
  const _ShiftForm({required this.shift});
  @override
  State<_ShiftForm> createState() => _ShiftFormState();
}

class _ShiftFormState extends State<_ShiftForm> {
  late bool isOff;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  @override
  void initState() {
    super.initState();
    isOff = widget.shift.isOff;
    startCtrl = TextEditingController(text: widget.shift.startTime);
    endCtrl = TextEditingController(text: widget.shift.endTime);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => isOff = !isOff),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isOff ? Colors.white.withValues(alpha:0.05) : AppTheme.primaryRed.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha:0.07)),
            ),
            child: Row(
              children: [
                Icon(isOff ? LucideIcons.toggleLeft : LucideIcons.toggleRight, color: isOff ? Colors.white24 : AppTheme.primaryRed),
                const SizedBox(width: 12),
                Text(
                  isOff ? l10n.translate('shift_off').toUpperCase() : l10n.translate('on_shift').toUpperCase(),
                  style: TextStyle(fontFamily: 'BarlowCondensed', fontWeight: FontWeight.w900, color: isOff ? Colors.white38 : AppTheme.primaryRed),
                ),
              ],
            ),
          ),
        ),
        if (!isOff) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput(l10n.translate('start_time').toUpperCase(), startCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildInput(l10n.translate('end_time').toUpperCase(), endCtrl)),
            ],
          ),
        ],
        const Spacer(),
        _buildSaveButton(() {
          context.read<ManagementCubit>().updateShift(widget.shift.coachId, widget.shift.day, startCtrl.text, endCtrl.text, isOff);
          Navigator.pop(context);
        }, l10n),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha:0.07))),
          ),
        ),
      ],
    );
  }
}

class _InBodyForm extends StatefulWidget {
  const _InBodyForm({super.key});

  @override
  State<_InBodyForm> createState() => _InBodyFormState();
}

class _InBodyFormState extends State<_InBodyForm> {
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  Map<String, dynamic>? selectedCoach;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ManagementCubit, ManagementState>(
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) return const SizedBox.shrink();
            final headCoachSex = authState.coach['sex'] ?? 'male';
            final coaches = state.allCoaches.where((c) => c['sex'] == headCoachSex).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput(
                  l10n.translate('date').toUpperCase(),
                  dateCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildInput(
                  l10n.translate('time').toUpperCase(),
                  timeCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      timeCtrl.text = picked.format(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('assign_shift').toUpperCase(),
                  style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha:0.07)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: selectedCoach,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1A1A),
                      hint: Text(l10n.translate('coach'), style: const TextStyle(color: Colors.white24, fontSize: 14)),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: coaches.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedCoach = val),
                    ),
                  ),
                ),
                const Spacer(),
                _buildSaveButton(() {
                  if (dateCtrl.text.isNotEmpty && timeCtrl.text.isNotEmpty && selectedCoach != null) {
                    context.read<ManagementCubit>().addInBodySlot(
                          dateCtrl.text,
                          timeCtrl.text,
                          selectedCoach!['uid'] ?? '',
                          selectedCoach!['name'] ?? '',
                          null,
                        );
                    Navigator.pop(context);
                  }
                }, l10n),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool readOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha:0.07))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha:0.07))),
          ),
        ),
      ],
    );
  }
}

class _DeductionForm extends StatelessWidget {
  const _DeductionForm();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const Text("Deduction Form implementation...", style: TextStyle(color: Colors.white24)),
        const Spacer(),
        _buildSaveButton(() => Navigator.pop(context), l10n),
      ],
    );
  }
}

Widget _buildSaveButton(VoidCallback onTap, AppLocalizations l10n) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Text(l10n.translate('save_changes').toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
      ),
    ),
  );
}
