import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/core/cubit/locale_cubit.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final coach = state.coach;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('nav_profile'),
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildProfileHeader(coach, isAr),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.translate('personal_info')),
                    const SizedBox(height: 12),
                    _buildInfoCard(coach['bio']?[isAr ? 'ar' : 'en'] ?? coach['bio'] ?? "N/A"),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.translate('muscle_group')), // Using as specialty for now or specialty key if I missed it
                    const SizedBox(height: 12),
                    _buildInfoCard(coach['specialty']?[isAr ? 'ar' : 'en'] ?? coach['specialty'] ?? "N/A"),
                    const SizedBox(height: 32),
                    _buildSectionHeader(l10n.translate('settings')),
                    const SizedBox(height: 12),
                    _buildLanguageToggle(context, l10n),
                    const SizedBox(height: 40),
                    _buildLogoutButton(context, l10n),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
      },
    );
  }

  Widget _buildLanguageToggle(BuildContext context, AppLocalizations l10n) {
    final localeCubit = context.read<LocaleCubit>();
    final isAr = localeCubit.state.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.globe, size: 20, color: Colors.white60),
              const SizedBox(width: 12),
              Text(
                l10n.translate('language'),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => localeCubit.setLocale('en'),
                child: Text(
                  "EN",
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: !isAr ? AppTheme.primaryRed : Colors.white24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 12, color: Colors.white10),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => localeCubit.setLocale('ar'),
                child: Text(
                  "AR",
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isAr ? AppTheme.primaryRed : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> coach, bool isAr) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.2), width: 2),
          ),
          child: Center(
            child: Text(
              (coach['name'] ?? 'C').substring(0, 1).toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coach['name'] ?? 'COACH',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Row(
                children: [
                  Text(
                    coach['email'] ?? '',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  if (coach['rating'] != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.star, size: 10, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      coach['rating'].toString(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (coach['role'] ?? 'COACH').toString().replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryRed,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.barlowCondensed(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.white.withValues(alpha: 0.3),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.read<AuthCubit>().logout(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, size: 18, color: AppTheme.primaryRed),
            const SizedBox(width: 12),
            Text(
              l10n.translate('logout').toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
