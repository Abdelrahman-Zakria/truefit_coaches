import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
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
  final List<String> _days = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"];

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
              const SizedBox(width: 120), // Matched with coach name width
              ..._days.map((d) => SizedBox(
                width: 70,
                child: Center(
                  child: Text(
                    d.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white, // Changed from white24
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
                  width: 120, // Increased from 80
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
                          // Removed overflow ellipsis and maxLines
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
                    Text(shift.startTime, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(shift.endTime, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha:0.6))),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInBodyTab(ManagementState state, AppLocalizations l10n) {
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    final headCoachSex = authState.coach['sex'] ?? 'male';
    final coaches = state.allCoaches.where((c) => c['sex'] == headCoachSex).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 120),
              ..._days.map((d) => SizedBox(
                width: 70,
                child: Center(
                  child: Text(
                    d.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'BarlowCondensed',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
                  width: 120,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha:0.15),
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
                        ),
                      ),
                    ],
                  ),
                ),
                ..._days.map((day) {
                  final slot = state.inBodySlots.firstWhere(
                    (s) => s.coachId == coach['uid'] && s.day == day,
                    orElse: () => InBodySlotModel(id: '', coachId: coach['uid'] ?? '', coachName: coach['name'] ?? '', day: day, startTime: '', endTime: '', isOff: true),
                  );
                  return _buildInBodyCell(slot, l10n);
                }),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInBodyCell(InBodySlot slot, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showInBodySlotEditor(slot, l10n),
      child: Container(
        width: 66,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: slot.isOff ? Colors.white.withValues(alpha:0.03) : Colors.blue.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: slot.isOff ? Colors.white.withValues(alpha:0.05) : Colors.blue.withValues(alpha:0.25),
          ),
        ),
        child: Center(
          child: slot.isOff
              ? Text(l10n.translate('off_shift').toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white24))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(slot.startTime, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(slot.endTime, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha:0.6))),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildClassesTab(ManagementState state) {
    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthCubit>().state;
    final bool isHeadCoach = authState is AuthAuthenticated && authState.coach['role'] == 'head_coach';

    // Extract unique branches from classes for the filter
    final availableBranches = <String, String>{}; // id -> display name
    for (var cls in state.classes) {
      if (cls.branchId == 'Rz6GfLSPaCEF0GUlOUc3' || cls.branchId == 'branch_1') {
        availableBranches['Rz6GfLSPaCEF0GUlOUc3'] = l10n.translate('branch_1');
      } else if (cls.branchId == 'f6Rd0gPflSRuW47UJFuD' || cls.branchId == 'branch_2') {
        availableBranches['f6Rd0gPflSRuW47UJFuD'] = l10n.translate('branch_2');
      } else {
        availableBranches[cls.branchId] = cls.branchName;
      }
    }

    // Filter classes based on selected branch and type (Free/Paid)
    final filteredClasses = state.classes.where((c) {
      final bool matchesBranch = state.selectedBranchId == null || c.branchId == state.selectedBranchId;
      final bool matchesIsFree = state.classIsFreeFilter == null || c.isFree == state.classIsFreeFilter;
      return matchesBranch && matchesIsFree;
    }).toList();

    // Group filtered classes by branch for better UX
    final branches = <String, List<GymClass>>{};
    for (var cls in filteredClasses) {
      String displayName = cls.branchName;
      if (cls.branchId == 'Rz6GfLSPaCEF0GUlOUc3' || cls.branchId == 'branch_1') {
        displayName = l10n.translate('branch_1');
      } else if (cls.branchId == 'f6Rd0gPflSRuW47UJFuD' || cls.branchId == 'branch_2') {
        displayName = l10n.translate('branch_2');
      }
      
      branches.putIfAbsent(displayName, () => []).add(cls);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHeadCoach) ...[
            _buildAddButton(l10n.translate('add_class').toUpperCase(), LucideIcons.plus, () => _showClassEditor(state, l10n)),
            const SizedBox(height: 16),
          ],

          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Branch Filter Chips
                if (availableBranches.isNotEmpty) ...[
                  _buildBranchChip(null, l10n.translate('see_all'), state.selectedBranchId == null),
                  ...availableBranches.entries.map((e) => _buildBranchChip(e.key, e.value, state.selectedBranchId == e.key)),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 24, color: Colors.white10),
                  const SizedBox(width: 16),
                ],

                // Paid/Free Filter Chips
                _buildTypeChip(null, "ALL", state.classIsFreeFilter == null),
                _buildTypeChip(true, l10n.translate('free'), state.classIsFreeFilter == true),
                _buildTypeChip(false, l10n.translate('paid'), state.classIsFreeFilter == false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...branches.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white24,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ...entry.value.map((cls) => _buildClassCard(cls, isHeadCoach, state)),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),

          if (filteredClasses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(LucideIcons.layoutGrid, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 16),
                    Text(l10n.translate('no_data').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(bool? isFree, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.white38,
          ),
        ),
        selected: isSelected,
        onSelected: (val) {
          if (val) context.read<ManagementCubit>().setClassIsFreeFilter(isFree);
        },
        selectedColor: AppTheme.primaryRed,
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.06)),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildBranchChip(String? id, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.white38,
          ),
        ),
        selected: isSelected,
        onSelected: (val) {
          if (val) context.read<ManagementCubit>().setSelectedBranch(id);
        },
        selectedColor: AppTheme.primaryRed,
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.06)),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildClassCard(GymClass cls, bool isHeadCoach, ManagementState state) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.locale.languageCode;
    final className = cls.name[locale] ?? cls.name['en'] ?? '';
    final progress = cls.maxCapacity > 0 ? cls.enrolled / cls.maxCapacity : 0.0;
    final isPT = cls.type == 'pt';
    final branchDisplayName = cls.branchId == 'branch_1' ? l10n.translate('branch_1') : (cls.branchId == 'branch_2' ? l10n.translate('branch_2') : cls.branchName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPT ? Colors.blue.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (isPT ? "PT" : "GROUP").toUpperCase(),
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isPT ? Colors.blue : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cls.day.toUpperCase(),
                          style: GoogleFonts.barlowCondensed(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryRed,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      className,
                      style: const TextStyle(
                        fontFamily: 'BarlowCondensed',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 10, color: Colors.white24),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            branchDisplayName,
                            style: const TextStyle(fontSize: 11, color: Colors.white38),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isHeadCoach)
                    IconButton(
                      onPressed: () => _confirmDeleteClass(cls),
                      icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.white24),
                    ),
                  Column(
                    children: [
                      Switch(
                        value: cls.isOpen,
                        onChanged: (val) => context.read<ManagementCubit>().toggleClass(cls.id, val),
                        activeThumbColor: Colors.green,
                      ),
                      Text(
                        cls.isOpen ? l10n.translate('open_btn') : l10n.translate('closed_class'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: cls.isOpen ? Colors.green : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${l10n.translate('capacity')}: ${cls.enrolled}/${cls.maxCapacity}",
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white60),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (isHeadCoach) {
                              _showClassFullEditor(cls, state, l10n);
                            } else {
                              _showCapacityEditor(cls);
                            }
                          },
                          child: const Icon(LucideIcons.edit3, size: 12, color: Colors.white24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(3),
                      ),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 12, color: Colors.white24),
                  const SizedBox(width: 4),
                  Text(
                    cls.coachName,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 12, color: Colors.white24),
                  const SizedBox(width: 4),
                  Text(
                    cls.time,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClass(GymClass cls) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.locale.languageCode;
    final className = cls.name[locale] ?? cls.name['en'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text("DELETE CLASS", style: GoogleFonts.barlowCondensed(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to delete '$className'?", style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel').toUpperCase())),
          TextButton(
            onPressed: () {
              context.read<ManagementCubit>().deleteClass(cls.id);
              Navigator.pop(context);
            },
            child: Text(l10n.translate('delete').toUpperCase(), style: const TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showClassEditor(ManagementState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: l10n.translate('add_class').toUpperCase(),
        heightFactor: 0.85,
        child: _ClassForm(allBranches: state.branches, allCoaches: state.allCoaches),
      ),
    );
  }

  void _showClassFullEditor(GymClass cls, ManagementState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: "EDIT CLASS",
        heightFactor: 0.85,
        child: _ClassForm(
          allBranches: state.branches,
          allCoaches: state.allCoaches,
          existingClass: cls,
        ),
      ),
    );
  }

  void _showCapacityEditor(GymClass cls) {
    final l10n = AppLocalizations.of(context);
    final TextEditingController capacityCtrl = TextEditingController(text: cls.maxCapacity.toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: "UPDATE CAPACITY",
        heightFactor: 0.4,
        child: Column(
          children: [
            TextField(
              controller: capacityCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.translate('capacity').toUpperCase(),
                labelStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
            _buildSaveButton(() {
              final newCap = int.tryParse(capacityCtrl.text);
              if (newCap != null) {
                context.read<ManagementCubit>().updateClassCapacity(cls.id, newCap);
                Navigator.pop(context);
              }
            }, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryTab(ManagementState state, List<Map<String, dynamic>> coaches, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (context.read<AuthCubit>().state is AuthAuthenticated && (context.read<AuthCubit>().state as AuthAuthenticated).coach['role'] == 'head_coach') ...[
            _buildAddButton(l10n.translate('add_deduction').toUpperCase(), LucideIcons.plus, () => _showDeductionEditor(state, l10n)),
            const SizedBox(height: 16),
          ],
          ...coaches.map((coach) {
            final coachDeds = state.deductions.where((d) => d.coachId == coach['uid']).toList();
            
            final coachData = {
              'id': coach['uid'],
              'name': coach['name'] ?? 'Coach',
              'avatar': (coach['name'] ?? 'C').substring(0, 1).toUpperCase(),
              'specialty': (coach['specialty'] is Map) 
                  ? (coach['specialty']['en'] ?? 'Trainer') 
                  : (coach['specialty'] ?? 'Trainer'),
            };

            return _buildCoachDeductionCard(coachData, coachDeds, l10n);
          }),
        ],
      ),
    );
  }

  Widget _buildCoachDeductionCard(Map<String, dynamic> coach, List<Deduction> deds, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
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
              if (deds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "${deds.length} ${l10n.translate('records')}",
                    style: GoogleFonts.barlowCondensed(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryRed),
                  ),
                ),
            ],
          ),
          if (deds.isEmpty) ...[
            const SizedBox(height: 16),
            Center(child: Text("No deductions recorded".toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 10, color: Colors.white12, letterSpacing: 1))),
          ] else ...[
            const SizedBox(height: 16),
            ...deds.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.reason, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(d.date, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white24)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      "-${d.days} DAYS",
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primaryRed),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
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

  void _showInBodySlotEditor(InBodySlot slot, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: "INBODY SCHEDULE",
        heightFactor: 0.55,
        child: _InBodyScheduleForm(slot: slot),
      ),
    );
  }

  void _showDeductionEditor(ManagementState state, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManagementBottomSheet(
        title: l10n.translate('add_deduction').toUpperCase(),
        heightFactor: 0.7,
        child: _DeductionForm(allCoaches: state.allCoaches),
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

class _InBodyScheduleForm extends StatefulWidget {
  final InBodySlot slot;
  const _InBodyScheduleForm({required this.slot});
  @override
  State<_InBodyScheduleForm> createState() => _InBodyScheduleFormState();
}

class _InBodyScheduleFormState extends State<_InBodyScheduleForm> {
  late bool isOff;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  @override
  void initState() {
    super.initState();
    isOff = widget.slot.isOff;
    startCtrl = TextEditingController(text: widget.slot.startTime);
    endCtrl = TextEditingController(text: widget.slot.endTime);
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
              color: isOff ? Colors.white.withValues(alpha:0.05) : Colors.blue.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha:0.07)),
            ),
            child: Row(
              children: [
                Icon(isOff ? LucideIcons.toggleLeft : LucideIcons.toggleRight, color: isOff ? Colors.white24 : Colors.blue),
                const SizedBox(width: 12),
                Text(
                  isOff ? l10n.translate('shift_off').toUpperCase() : "INBODY DUTY".toUpperCase(),
                  style: TextStyle(fontFamily: 'BarlowCondensed', fontWeight: FontWeight.w900, color: isOff ? Colors.white38 : Colors.blue),
                ),
              ],
            ),
          ),
        ),
        if (!isOff) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  l10n.translate('start_time').toUpperCase(),
                  startCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) setState(() => startCtrl.text = picked.format(context));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  l10n.translate('end_time').toUpperCase(),
                  endCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) setState(() => endCtrl.text = picked.format(context));
                  },
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
        _buildSaveButton(() {
          context.read<ManagementCubit>().updateInBodySlot(
                widget.slot.coachId,
                widget.slot.coachName,
                widget.slot.day,
                startCtrl.text,
                endCtrl.text,
                isOff,
              );
          Navigator.pop(context);
        }, l10n),
      ],
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

class _DeductionForm extends StatefulWidget {
  final List<Map<String, dynamic>> allCoaches;

  const _DeductionForm({required this.allCoaches});

  @override
  State<_DeductionForm> createState() => _DeductionFormState();
}

class _DeductionFormState extends State<_DeductionForm> {
  Map<String, dynamic>? selectedCoach;
  final TextEditingController reasonCtrl = TextEditingController();
  double selectedDays = 1.0;
  final List<double> dayOptions = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.read<AuthCubit>().state as AuthAuthenticated;
    final headCoachSex = authState.coach['sex'] ?? 'male';
    final filteredCoaches = widget.allCoaches.where((c) => c['sex'] == headCoachSex).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown<Map<String, dynamic>>(
          label: l10n.translate('coach'),
          value: selectedCoach,
          items: filteredCoaches,
          onChanged: (val) => setState(() => selectedCoach = val),
          itemLabel: (c) => c['name'] ?? 'Unknown',
        ),
        const SizedBox(height: 16),
        _buildInput(l10n.translate('reason'), reasonCtrl),
        const SizedBox(height: 24),
        Text(
          "DEDUCTION DAYS",
          style: GoogleFonts.barlowCondensed(fontSize: 10, color: Colors.white24, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dayOptions.map((d) {
            final isSelected = selectedDays == d;
            return GestureDetector(
              onTap: () => setState(() => selectedDays = d),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppTheme.primaryRed : Colors.white10),
                ),
                child: Text(
                  "$d DAYS",
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        _buildSaveButton(() {
          if (selectedCoach != null && reasonCtrl.text.isNotEmpty) {
            context.read<ManagementCubit>().addDeduction(
              selectedCoach!['uid'],
              selectedDays,
              reasonCtrl.text,
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
          }
        }, l10n),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              hint: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 14)),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
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

class _ClassForm extends StatefulWidget {
  final List<Branch> allBranches;
  final List<Map<String, dynamic>> allCoaches;
  final GymClass? existingClass; // Added for editing

  const _ClassForm({required this.allBranches, required this.allCoaches, this.existingClass});

  @override
  State<_ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends State<_ClassForm> {
  final TextEditingController nameEnCtrl = TextEditingController();
  final TextEditingController nameArCtrl = TextEditingController();
  final TextEditingController timeCtrl = TextEditingController();
  final TextEditingController capacityCtrl = TextEditingController(text: "20");
  final TextEditingController durationCtrl = TextEditingController(text: "60");
  
  // Pricing Controllers
  final TextEditingController p1Ctrl = TextEditingController(text: "100");
  final TextEditingController p4Ctrl = TextEditingController(text: "300");
  final TextEditingController p8Ctrl = TextEditingController(text: "500");
  final TextEditingController p12Ctrl = TextEditingController(text: "700");

  Branch? selectedBranch;
  Map<String, dynamic>? selectedCoach;
  String selectedDay = "Monday";
  bool isFree = true;

  final List<String> _days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  @override
  void initState() {
    super.initState();
    if (widget.existingClass != null) {
      final cls = widget.existingClass!;
      nameEnCtrl.text = cls.name['en'] ?? '';
      nameArCtrl.text = cls.name['ar'] ?? '';
      timeCtrl.text = cls.time;
      capacityCtrl.text = cls.maxCapacity.toString();
      durationCtrl.text = cls.duration;
      isFree = cls.isFree;
      selectedDay = cls.day;
      
      // Initialize pricing if exists
      if (cls.pricing != null) {
        p1Ctrl.text = cls.pricing!['session_1']?['price']?.toString() ?? '100';
        p4Ctrl.text = cls.pricing!['session_4']?['price']?.toString() ?? '300';
        p8Ctrl.text = cls.pricing!['session_8']?['price']?.toString() ?? '500';
        p12Ctrl.text = cls.pricing!['session_12']?['price']?.toString() ?? '700';
      }

      // Pre-select Branch
      try {
        selectedBranch = widget.allBranches.firstWhere((b) => b.id == cls.branchId);
      } catch (_) {}

      // Pre-select Coach
      try {
        selectedCoach = widget.allCoaches.firstWhere((c) => c['uid'] == cls.instructorId);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildInput(l10n.translate('class_name_en'), nameEnCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildInput(l10n.translate('class_name_ar'), nameArCtrl)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<Branch>(
                  label: l10n.translate('location'),
                  value: selectedBranch,
                  items: widget.allBranches,
                  onChanged: (val) => setState(() => selectedBranch = val),
                  itemLabel: (b) => b.name,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<Map<String, dynamic>>(
                  label: l10n.translate('coach'),
                  value: selectedCoach,
                  items: widget.allCoaches,
                  onChanged: (val) => setState(() => selectedCoach = val),
                  itemLabel: (c) => c['name'] ?? 'Unknown',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<String>(
                  label: l10n.translate('days'),
                  value: selectedDay,
                  items: _days,
                  onChanged: (val) => setState(() => selectedDay = val!),
                  itemLabel: (d) => d,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  l10n.translate('time'),
                  timeCtrl,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) setState(() => timeCtrl.text = picked.format(context));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput(l10n.translate('capacity'), capacityCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildInput(l10n.translate('duration'), durationCtrl, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 20),
          // Type Toggle (Free/Paid)
          GestureDetector(
            onTap: () => setState(() => isFree = !isFree),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFree ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isFree ? Colors.green.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(isFree ? LucideIcons.unlock : LucideIcons.lock, color: isFree ? Colors.green : Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    isFree ? "FREE GROUP CLASS" : "PAID PT CLASS",
                    style: GoogleFonts.barlowCondensed(
                      fontWeight: FontWeight.w900,
                      color: isFree ? Colors.green : Colors.blue,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Switch(value: isFree, onChanged: (val) => setState(() => isFree = val), activeColor: Colors.green),
                ],
              ),
            ),
          ),
          
          if (!isFree) ...[
            const SizedBox(height: 24),
            Text(
              "PRICING PLANS (EGP)",
              style: GoogleFonts.barlowCondensed(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInput("1 Session", p1Ctrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput("4 Sessions", p4Ctrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInput("8 Sessions", p8Ctrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput("12 Sessions", p12Ctrl, keyboardType: TextInputType.number)),
              ],
            ),
          ],

          const SizedBox(height: 32),
          _buildSaveButton(() {
            if (_validate()) {
              final newClass = GymClassModel(
                id: widget.existingClass?.id ?? '', 
                name: {'en': nameEnCtrl.text, 'ar': nameArCtrl.text},
                coachName: selectedCoach!['name'],
                instructorId: selectedCoach!['uid'],
                branchId: selectedBranch!.id,
                branchName: selectedBranch!.name,
                day: selectedDay,
                time: timeCtrl.text,
                duration: durationCtrl.text,
                maxCapacity: int.parse(capacityCtrl.text),
                enrolled: widget.existingClass?.enrolled ?? 0,
                isOpen: widget.existingClass?.isOpen ?? true,
                type: isFree ? 'group' : 'pt',
                isFree: isFree,
                pricing: isFree ? null : {
                  'session_1': {'price': double.parse(p1Ctrl.text), 'sessions': 1, 'expire_days': null},
                  'session_4': {'price': double.parse(p4Ctrl.text), 'sessions': 4, 'expire_days': 15},
                  'session_8': {'price': double.parse(p8Ctrl.text), 'sessions': 8, 'expire_days': 30},
                  'session_12': {'price': double.parse(p12Ctrl.text), 'sessions': 12, 'expire_days': 45},
                },
              );
              
              if (widget.existingClass == null) {
                context.read<ManagementCubit>().addClass(newClass);
              } else {
                context.read<ManagementCubit>().updateClass(newClass);
              }
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
            }
          }, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  bool _validate() {
    return nameEnCtrl.text.isNotEmpty &&
        nameArCtrl.text.isNotEmpty &&
        timeCtrl.text.isNotEmpty &&
        selectedBranch != null &&
        selectedCoach != null;
  }

  Widget _buildInput(String label, TextEditingController ctrl, {bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontFamily: 'BarlowCondensed', fontSize: 10, color: Colors.white24, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              hint: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 14)),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
