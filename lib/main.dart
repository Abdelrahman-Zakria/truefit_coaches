import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:truefit_coaches/firebase_options.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/services/location_service.dart';
import 'package:truefit_coaches/core/cubit/locale_cubit.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:truefit_coaches/features/home/presentation/cubit/home_cubit.dart';
import 'package:truefit_coaches/features/members/presentation/cubit/members_cubit.dart';
import 'package:truefit_coaches/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:truefit_coaches/features/chat/presentation/cubit/list/chat_list_cubit.dart';
import 'package:truefit_coaches/features/chat/presentation/cubit/room/chat_room_cubit.dart';
import 'package:truefit_coaches/features/management/data/datasources/management_remote_datasource.dart';
import 'package:truefit_coaches/features/management/presentation/cubit/management_cubit.dart';
import 'package:truefit_coaches/features/home/presentation/pages/main_wrapper.dart';
import 'package:truefit_coaches/features/auth/presentation/pages/login_screen.dart';
import 'package:truefit_coaches/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:truefit_coaches/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:truefit_coaches/features/time_tracking/presentation/cubit/time_tracking_cubit.dart';
import 'package:truefit_coaches/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:truefit_coaches/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:truefit_coaches/features/auth/presentation/pages/splash_screen.dart';
import 'package:truefit_coaches/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await NotificationService.init();
  
  final prefs = await SharedPreferences.getInstance();
  await LocationService.requestPermission();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocaleCubit(prefs)),
        BlocProvider(create: (context) => AuthCubit(prefs)),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => MembersCubit()),
        BlocProvider(create: (context) => AttendanceCubit()),
        BlocProvider(create: (context) => ChatListCubit()),
        BlocProvider(create: (context) => ChatRoomCubit()),
        BlocProvider(create: (context) => ManagementCubit(ManagementRemoteDataSourceImpl())),
        BlocProvider(create: (context) => ScheduleCubit(ScheduleRemoteDataSourceImpl())),
        BlocProvider(create: (context) => TimeTrackingCubit()),
        BlocProvider(create: (context) => RequestsCubit(RequestsRemoteDataSourceImpl())),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Truefit Coaches',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onDone: () {
        setState(() => _showSplash = false);
      });
    }

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainWrapper();
        }
        return LoginScreen();
      },
    );
  }
}
