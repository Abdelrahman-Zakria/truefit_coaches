import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/home/presentation/cubit/home_cubit.dart';
import 'package:truefit_coaches/features/members/presentation/cubit/members_cubit.dart';
import 'package:truefit_coaches/features/chat/presentation/cubit/list/chat_list_cubit.dart';
import 'package:truefit_coaches/features/time_tracking/presentation/cubit/time_tracking_cubit.dart';
import 'package:truefit_coaches/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:truefit_coaches/features/home/presentation/pages/dashboard_screen.dart';
import 'package:truefit_coaches/features/members/presentation/pages/member_list_screen.dart';
import 'package:truefit_coaches/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:truefit_coaches/features/schedule/presentation/pages/schedule_screen.dart';
import 'package:truefit_coaches/features/home/presentation/pages/profile_screen.dart';
import 'package:truefit_coaches/features/management/presentation/pages/management_screen.dart';
import 'package:truefit_coaches/core/services/notification_service.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  static _MainWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainWrapperState>();
  }

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final coachId = authState.coach['uid'];
        context.read<HomeCubit>().watchDashboard(coachId);
        context.read<MembersCubit>().watchMembers(coachId);
        context.read<ChatListCubit>().watchConversations(coachId);
        context.read<TimeTrackingCubit>().watchTimeEntries(coachId);
        context.read<RequestsCubit>().watchRequests(coachId);
        NotificationService.updateToken(coachId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        bool isHeadCoach = false;
        if (state is AuthAuthenticated) {
          isHeadCoach = state.coach['role'] == 'head_coach';
        }

        final List<Widget> pages = [
          const DashboardScreen(),
          const ScheduleScreen(),
          const MemberListScreen(),
          const ChatListScreen(),
          const ProfileScreen(),
          if (isHeadCoach) const ManagementScreen(),
        ];

        return Scaffold(
          body: pages[_selectedIndex < pages.length ? _selectedIndex : 0],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderGrey, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.home),
                  activeIcon: const Icon(LucideIcons.home, color: AppTheme.primaryRed),
                  label: AppLocalizations.of(context).translate('nav_home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.calendarDays),
                  activeIcon: const Icon(LucideIcons.calendarDays, color: AppTheme.primaryRed),
                  label: AppLocalizations.of(context).translate('nav_schedule'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.users),
                  activeIcon: const Icon(LucideIcons.users, color: AppTheme.primaryRed),
                  label: AppLocalizations.of(context).translate('nav_members'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.messageSquare),
                  activeIcon: const Icon(LucideIcons.messageSquare, color: AppTheme.primaryRed),
                  label: AppLocalizations.of(context).translate('nav_chat'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(LucideIcons.user),
                  activeIcon: const Icon(LucideIcons.user, color: AppTheme.primaryRed),
                  label: AppLocalizations.of(context).translate('nav_profile'),
                ),
                if (isHeadCoach)
                  BottomNavigationBarItem(
                    icon: const Icon(LucideIcons.layoutGrid),
                    activeIcon: const Icon(LucideIcons.layoutGrid, color: AppTheme.primaryRed),
                    label: AppLocalizations.of(context).translate('nav_management'),
                  ),
              ],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: AppTheme.backgroundBlack,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryRed,
              unselectedItemColor: Colors.white24,
            ),
          ),
        );
      },
    );
  }
}
