import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/core/widgets/skeleton_loading.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/members/presentation/cubit/members_cubit.dart';
import 'package:truefit_coaches/features/members/presentation/pages/member_profile_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<MembersCubit>().watchMembers(authState.coach['uid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.translate('nav_members').toUpperCase(),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(l10n),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<MembersCubit, MembersState>(
                  builder: (context, state) {
                    if (state is MembersLoading) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: SkeletonLoading(
                            width: double.infinity,
                            height: 84,
                            borderRadius: 24,
                          ),
                        ),
                      );
                    }
                    if (state is MembersLoaded) {
                      return ListView.builder(
                        itemCount: state.members.length,
                        itemBuilder: (context, index) {
                          final member = state.members[index];
                          return _buildMemberCard(context, member);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => context.read<MembersCubit>().searchMembers(value),
        decoration: InputDecoration(
          hintText: l10n.translate('search'),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          prefixIcon: Icon(LucideIcons.search, color: Colors.white.withValues(alpha: 0.2), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberProfileScreen(member: member),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  member['initials'] ?? member['member_name']?.substring(0, 1) ?? 'M',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 18,
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
                    member['member_name'] ?? member['name'] ?? 'Member',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          member['plan'] ?? AppLocalizations.of(context).translate('active'),
                          style: GoogleFonts.barlowCondensed(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                      ),
                      if (member['pt_wallet'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${member['pt_wallet']['sessions_left']}/${member['pt_wallet']['total']} PT",
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _buildProgressIndicator(member['progress'] ?? 0),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, color: Colors.white.withValues(alpha: 0.1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int progress) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 3,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
          Text(
            "$progress%",
            style: GoogleFonts.barlowCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
