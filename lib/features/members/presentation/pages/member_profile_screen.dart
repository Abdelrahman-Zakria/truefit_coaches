import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/members/presentation/cubit/members_cubit.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/entities/inbody_scan_entity.dart';
import '../../domain/entities/diet_plan_entity.dart';
import '../../domain/entities/assessment_entity.dart';
import '../../data/models/diet_plan_model.dart';

class MemberProfileScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  const MemberProfileScreen({super.key, required this.member});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabKeys = ["overview", "workouts", "inbody", "diet_plan", "assessment", "sessions"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabKeys.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    final persId = widget.member['pers_id'] ?? widget.member['pers_data']?['pers_ID'];
    if (persId != null) {
      context.read<MembersCubit>().watchMemberDetails(persId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            _buildTabBar(l10n),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(l10n),
                  _buildWorkoutsTab(l10n),
                  _buildInBodyTab(l10n),
                  _buildDietPlanTab(l10n),
                  _buildAssessmentTab(l10n),
                  _buildSessionsTab(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final persData = widget.member['pers_data'] as Map<String, dynamic>? ?? {};
    final String name = persData['pers_NAME_EN'] ?? widget.member['member_name'] ?? 'Member';
    final String initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'M';
    final String birthDate = persData['DATE_BIRTH'] ?? '';
    String ageStr = "N/A";
    
    if (birthDate.isNotEmpty) {
      try {
        final birth = DateTime.parse(birthDate);
        final now = DateTime.now();
        int age = now.year - birth.year;
        if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
        ageStr = "${l10n.translate('age')} $age";
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(LucideIcons.chevronLeft, size: 16, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  l10n.translate('all_members').toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 14,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withValues(alpha:0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.member['plan'] ?? l10n.translate('active'),
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ageStr,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildProgressRing(widget.member['progress'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(int progress) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha:0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          Text(
            "$progress%",
            style: GoogleFonts.barlowCondensed(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.only(right: 8),
        tabs: _tabKeys.asMap().entries.map((entry) => _buildTabItem(entry.value, l10n, entry.key)).toList(),
      ),
    );
  }

  Widget _buildTabItem(String key, AppLocalizations l10n, int index) {
    bool isSelected = _tabController.index == index;
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha:0.06),
          ),
        ),
        child: Text(
          l10n.translate(key).toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.4),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AppLocalizations l10n) {
    final persData = widget.member['pers_data'] as Map<String, dynamic>? ?? {};
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        InBodyScan? latestScan;
        if (state is MembersLoaded && state.currentMemberInBodyScans.isNotEmpty) {
          latestScan = state.currentMemberInBodyScans.first;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildField(l10n.translate('phone_field'), persData['Tel_Mobile1'] ?? "N/A"),
                  _buildField(l10n.translate('email_field'), persData['E_mail'] != null && persData['E_mail'].isNotEmpty ? persData['E_mail'] : "N/A"),
                  _buildField(l10n.translate('address_field'), persData['ADDRESS'] ?? "N/A"),
                  _buildField(l10n.translate('join_date'), (persData['LogTime'] ?? '').split('T').first),
                  _buildField(l10n.translate('member_id'), persData['pers_ID']?.toString() ?? "N/A"),
                  _buildField(l10n.translate('status'), persData['pers_Status'] == 2 ? "Active" : "Inactive"),
                  if (widget.member['pt_wallet'] != null)
                    _buildField(
                      l10n.translate('sessions_left'), 
                      "${widget.member['pt_wallet']['sessions_left']} / ${widget.member['pt_wallet']['total']}",
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('latest_inbody'),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInBodyStat(l10n.translate('weight'), latestScan != null ? "${latestScan.weight}kg" : "--"),
                  const SizedBox(width: 8),
                  _buildInBodyStat(l10n.translate('body_fat'), latestScan != null ? "${latestScan.bodyFatPct}%" : "--"),
                  const SizedBox(width: 8),
                  _buildInBodyStat(l10n.translate('muscle'), latestScan != null ? "${latestScan.muscleMass}kg" : "--"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab(AppLocalizations l10n) {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          final exercises = state.currentMemberWorkout?.exercises ?? [];

          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.dumbbell, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_workout'),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildActionBtn(
                LucideIcons.plus, 
                l10n.translate('add_exercise'), 
                onTap: () => _showAddExerciseSheet(context, l10n),
              ),
              const SizedBox(height: 16),
              ...exercises.asMap().entries.map((entry) => _buildExerciseItem(
                    entry.value.name,
                    "General", 
                    entry.value.weight,
                    entry.value.sets,
                    entry.value.reps,
                    onDelete: () => context.read<MembersCubit>().deleteExercise(
                      widget.member['pers_data']['pers_ID'],
                      entry.key,
                    ),
                    onTap: () => _showEditExerciseSheet(context, entry.value, entry.key, l10n),
                  )),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  Widget _buildInBodyTab(AppLocalizations l10n) {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          final scans = state.currentMemberInBodyScans;

          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.activity, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_scans'),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<FlSpot> spots = [];
          for (int i = 0; i < scans.length; i++) {
            spots.add(FlSpot(i.toDouble(), scans[i].weight));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildActionBtn(LucideIcons.plus, l10n.translate('new_scan')),
              const SizedBox(height: 16),
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('weight_trend'),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white38,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppTheme.primaryRed,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...scans.reversed.map((s) => _buildInBodyScanCard(
                    s.date,
                    s.weight,
                    s.bodyFatPct,
                    s.muscleMass,
                    s.bmi,
                    s.hydration,
                    l10n,
                  )),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  Widget _buildDietPlanTab(AppLocalizations l10n) {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          final diet = state.currentMemberDietPlan;

          if (diet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.utensils, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_diet'),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildActionBtn(
                LucideIcons.plus, 
                l10n.translate('add_meal'),
                onTap: () => _showMealEditor(null, diet, l10n), 
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showGoalsEditor(diet, l10n),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.translate('daily_totals'),
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white38,
                              letterSpacing: 1,
                            ),
                          ),
                          const Icon(LucideIcons.pencil, size: 12, color: Colors.white24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDietTotal(diet.totalCalories, "kcal"),
                          _buildDietTotal(diet.proteinGoal, "protein"),
                          _buildDietTotal(diet.carbsGoal, "carbs"),
                          _buildDietTotal(diet.fatsGoal, "fat"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...diet.meals.map((m) => _buildMealItem(m, diet, l10n)),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  void _showGoalsEditor(DietPlan diet, AppLocalizations l10n) {
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
            Text(l10n.translate('edit_goals').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Goal editor form will go here...", style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 40),
            _buildActionBtn(LucideIcons.check, l10n.translate('save_changes').toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentTab(AppLocalizations l10n) {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        if (state is MembersError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        if (state is MembersLoaded) {
          final assessments = state.currentMemberAssessments;

          if (assessments.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildActionBtn(
                  LucideIcons.plus, 
                  l10n.translate('new_assessment'),
                  onTap: () => _showAddAssessmentSheet(context, null, l10n),
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.clipboardList, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('no_assessments'),
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.2),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildActionBtn(
                LucideIcons.plus, 
                l10n.translate('new_assessment'),
                onTap: () => _showAddAssessmentSheet(context, null, l10n),
              ),
              const SizedBox(height: 16),
              ...assessments.map((a) => _buildAssessmentCard(a, l10n)),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  Widget _buildSessionsTab(AppLocalizations l10n) {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        if (state is MembersLoaded) {
          final sessions = state.currentMemberSessions;

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendar, size: 48, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_sessions_found').toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              return _buildPastSessionItem(s.date, s.duration, "${s.time} · ${s.status.toUpperCase()}");
            },
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  Widget _buildActionBtn(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.barlowCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseSheet(BuildContext context, AppLocalizations l10n) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

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
            Text(l10n.translate('add_exercise').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),
            _buildModalInput(l10n.translate('exercise_name'), nameCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildModalInput(l10n.translate('sets'), setsCtrl, type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildModalInput("Reps", repsCtrl, type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildModalInput("${l10n.translate('weight')} (kg)", weightCtrl, type: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionBtn(
              LucideIcons.check, 
              l10n.translate('save_exercise').toUpperCase(), 
              onTap: () {
                if (nameCtrl.text.isNotEmpty) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    final newEx = Exercise(
                      name: nameCtrl.text,
                      sets: int.tryParse(setsCtrl.text) ?? 0,
                      reps: int.tryParse(repsCtrl.text) ?? 0,
                      weight: double.tryParse(weightCtrl.text) ?? 0.0,
                    );
                    context.read<MembersCubit>().addExercise(
                      widget.member['pers_data']['pers_ID'],
                      newEx,
                      authState.coach['uid'],
                    );
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExerciseSheet(BuildContext context, Exercise exercise, int index, AppLocalizations l10n) {
    final nameCtrl = TextEditingController(text: exercise.name);
    final setsCtrl = TextEditingController(text: exercise.sets.toString());
    final repsCtrl = TextEditingController(text: exercise.reps.toString());
    final weightCtrl = TextEditingController(text: exercise.weight.toString());

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
            Text(l10n.translate('edit_exercise').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),
            _buildModalInput(l10n.translate('exercise_name'), nameCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildModalInput(l10n.translate('sets'), setsCtrl, type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildModalInput("Reps", repsCtrl, type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildModalInput("${l10n.translate('weight')} (kg)", weightCtrl, type: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionBtn(
              LucideIcons.check, 
              l10n.translate('save_changes').toUpperCase(), 
              onTap: () {
                if (nameCtrl.text.isNotEmpty) {
                  final updatedEx = Exercise(
                    name: nameCtrl.text,
                    sets: int.tryParse(setsCtrl.text) ?? 0,
                    reps: int.tryParse(repsCtrl.text) ?? 0,
                    weight: double.tryParse(weightCtrl.text) ?? 0.0,
                  );
                  context.read<MembersCubit>().updateExercise(
                    widget.member['pers_data']['pers_ID'],
                    index,
                    updatedEx,
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String group, double weight, int sets, int reps, {VoidCallback? onDelete, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha:0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.pencil, size: 12, color: Colors.white.withValues(alpha: 0.2)),
                    ],
                  ),
                  Text(
                    group,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha:0.4)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        weight > 0 ? "${weight.toInt()}kg" : "BW",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha:0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$sets × $reps",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(LucideIcons.trash2, size: 16, color: Colors.white.withValues(alpha:0.25)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInBodyScanCard(String date, double weight, double fat, double muscle, double bmi, double hydration, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha:0.4),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.translate('inbody').toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInBodyMetric(weight.toString(), l10n.translate('weight')),
              _buildInBodyMetric("$fat%", l10n.translate('body_fat')),
              _buildInBodyMetric(muscle.toString(), l10n.translate('muscle')),
              _buildInBodyMetric(bmi.toString(), "BMI"),
              _buildInBodyMetric("$hydration%", l10n.translate('hydration')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInBodyMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.barlowCondensed(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 9,
            color: Colors.white.withValues(alpha:0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDietTotal(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.barlowCondensed(
            fontSize: 10,
            color: Colors.white.withValues(alpha:0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(Meal meal, DietPlan diet, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
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
                    meal.title,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    meal.time,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.pencil, size: 16, color: Colors.white.withValues(alpha:0.25)),
                    onPressed: () => _showMealEditor(meal, diet, l10n),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 16, color: Colors.white.withValues(alpha:0.25)),
                    onPressed: () => context.read<MembersCubit>().deleteMeal(
                      widget.member['pers_data']['pers_ID'],
                      meal.id,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: meal.items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "${meal.calories} kcal",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "P:${meal.protein} C:${meal.carbs} F:${meal.fats}",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha:0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMealEditor(Meal? meal, DietPlan diet, AppLocalizations l10n) {
    final titleCtrl = TextEditingController(text: meal?.title ?? '');
    final timeCtrl = TextEditingController(text: meal?.time ?? '');
    final calCtrl = TextEditingController(text: meal?.calories.toString() ?? '0');
    final pCtrl = TextEditingController(text: meal?.protein.toString() ?? '0');
    final cCtrl = TextEditingController(text: meal?.carbs.toString() ?? '0');
    final fCtrl = TextEditingController(text: meal?.fats.toString() ?? '0');
    final itemsList = List<String>.from(meal?.items ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal == null ? l10n.translate('add_meal').toUpperCase() : l10n.translate('edit').toUpperCase(), 
                  style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)
                ),
                const SizedBox(height: 20),
                _buildModalInput(l10n.translate('meal_name'), titleCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildModalInput(
                  l10n.translate('time'), 
                  timeCtrl, 
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      final now = DateTime.now();
                      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                      timeCtrl.text = DateFormat('hh:mm a').format(dt);
                    }
                  },
                ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModalInput(l10n.translate('calories'), calCtrl, type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildModalInput(l10n.translate('protein'), pCtrl, type: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModalInput(l10n.translate('carbs'), cCtrl, type: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildModalInput(l10n.translate('fat'), fCtrl, type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.translate('items').toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1)),
                const SizedBox(height: 12),
                ...itemsList.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.value, style: const TextStyle(color: Colors.white70)),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.white24),
                        onPressed: () => setModalState(() => itemsList.removeAt(entry.key)),
                      ),
                    ],
                  ),
                )),
                TextButton.icon(
                  onPressed: () {
                    final itemCtrl = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        title: Text(l10n.translate('add_item')),
                        content: TextField(controller: itemCtrl, style: const TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
                          TextButton(
                            onPressed: () {
                              if (itemCtrl.text.isNotEmpty) {
                                setModalState(() => itemsList.add(itemCtrl.text));
                              }
                              Navigator.pop(context);
                            }, 
                            child: Text(l10n.translate('add')),
                          ),
                        ],
                      ),
                    );
                  }, 
                  icon: const Icon(LucideIcons.plus, size: 16), 
                  label: Text(l10n.translate('add_item').toUpperCase()),
                ),
                const SizedBox(height: 32),
                _buildActionBtn(LucideIcons.check, l10n.translate('save_changes').toUpperCase(), onTap: () {
                  final updatedMeal = MealModel(
                    id: meal?.id ?? 'm_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text,
                    time: timeCtrl.text,
                    calories: int.tryParse(calCtrl.text) ?? 0,
                    protein: int.tryParse(pCtrl.text) ?? 0,
                    carbs: int.tryParse(cCtrl.text) ?? 0,
                    fats: int.tryParse(fCtrl.text) ?? 0,
                    items: itemsList,
                  );
                  
                  List<Meal> updatedMeals;
                  if (meal == null) {
                    updatedMeals = List<Meal>.from(diet.meals)..add(updatedMeal);
                  } else {
                    updatedMeals = diet.meals.map((m) => m.id == meal.id ? updatedMeal : m).toList();
                  }

                  final updatedDiet = DietPlanModel(
                    id: diet.id,
                    totalCalories: diet.totalCalories,
                    proteinGoal: diet.proteinGoal,
                    carbsGoal: diet.carbsGoal,
                    fatsGoal: diet.fatsGoal,
                    waterGoal: diet.waterGoal,
                    currentWater: diet.currentWater,
                    meals: updatedMeals,
                  );

                  context.read<MembersCubit>().updateDietPlan(
                    widget.member['pers_data']['pers_ID'], 
                    updatedDiet
                  );
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAssessmentSheet(BuildContext context, Assessment? assessment, AppLocalizations l10n) {
    final dateCtrl = TextEditingController(text: assessment?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final levelCtrl = TextEditingController(text: assessment?.level ?? '');
    final goalsCtrl = TextEditingController(text: assessment?.goals ?? '');
    final injuriesCtrl = TextEditingController(text: assessment?.injuries ?? '');
    final remarksCtrl = TextEditingController(text: assessment?.remarks ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (assessment == null ? l10n.translate('new_assessment') : l10n.translate('edit')).toUpperCase(), 
                style: GoogleFonts.barlowCondensed(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)
              ),
              const SizedBox(height: 20),
              _buildModalInput(l10n.translate('date'), dateCtrl, readOnly: true, onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              }),
              const SizedBox(height: 12),
              _buildModalInput(l10n.translate('level'), levelCtrl, hint: "e.g. Intermediate"),
              const SizedBox(height: 12),
              _buildModalInput(l10n.translate('goals'), goalsCtrl, hint: "e.g. Muscle gain"),
              const SizedBox(height: 12),
              _buildModalInput(l10n.translate('injuries'), injuriesCtrl, hint: "Optional"),
              const SizedBox(height: 12),
              _buildModalInput(l10n.translate('coach_remarks'), remarksCtrl, maxLines: 3),
              const SizedBox(height: 32),
              _buildActionBtn(
                LucideIcons.check, 
                l10n.translate('save').toUpperCase(), 
                onTap: () {
                  if (levelCtrl.text.isNotEmpty && goalsCtrl.text.isNotEmpty) {
                    final persIdRaw = widget.member['pers_id'] ?? widget.member['pers_data']?['pers_ID'];
                    int? memberId;
                    if (persIdRaw is int) {
                      memberId = persIdRaw;
                    } else if (persIdRaw is String) {
                      memberId = int.tryParse(persIdRaw);
                    }

                    if (memberId == null) return;

                    if (assessment == null) {
                      final newAssessment = Assessment(
                        id: '',
                        memberId: memberId,
                        date: dateCtrl.text,
                        level: levelCtrl.text,
                        goals: goalsCtrl.text,
                        injuries: injuriesCtrl.text.isEmpty ? null : injuriesCtrl.text,
                        remarks: remarksCtrl.text,
                      );
                      context.read<MembersCubit>().addAssessment(memberId, newAssessment);
                    } else {
                      final updated = Assessment(
                        id: assessment.id,
                        memberId: memberId,
                        date: dateCtrl.text,
                        level: levelCtrl.text,
                        goals: goalsCtrl.text,
                        injuries: injuriesCtrl.text.isEmpty ? null : injuriesCtrl.text,
                        remarks: remarksCtrl.text,
                      );
                      context.read<MembersCubit>().updateAssessment(updated);
                    }
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalInput(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text, bool readOnly = false, VoidCallback? onTap, String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.barlowCondensed(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentCard(Assessment assessment, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                assessment.date,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha:0.4),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      assessment.level.toUpperCase(),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 14, color: Colors.white24),
                    onPressed: () => _showAddAssessmentSheet(context, assessment, l10n),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.white24),
                    onPressed: () => _showDeleteConfirmation(context, assessment),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAssessmentField(l10n.translate('goals').toUpperCase(), assessment.goals),
          if (assessment.injuries != null) ...[
            const SizedBox(height: 12),
            _buildAssessmentField(l10n.translate('injuries').toUpperCase(), assessment.injuries!, color: const Color(0xFFF59E0B)),
          ],
          const SizedBox(height: 12),
          _buildAssessmentField(l10n.translate('coach_remarks').toUpperCase(), assessment.remarks, isSubtle: true),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Assessment assessment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(AppLocalizations.of(context).translate('delete').toUpperCase(), 
                   style: GoogleFonts.barlowCondensed(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this assessment?", 
                     style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('cancel'), style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              context.read<MembersCubit>().deleteAssessment(assessment.id);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate('delete'), style: const TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentField(String label, String value, {Color color = Colors.white, bool isSubtle = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.barlowCondensed(
              fontSize: 10,
              color: Colors.white.withValues(alpha:0.3),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isSubtle ? Colors.white70 : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastSessionItem(String date, int duration, String notes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha:0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "PT",
                style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notes,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "$date · ${duration}min",
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha:0.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.barlowCondensed(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInBodyStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.barlowCondensed(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.barlowCondensed(
                fontSize: 10,
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
