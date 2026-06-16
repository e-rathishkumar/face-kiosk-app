import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/attendance/attendance_bloc.dart';
import '../blocs/attendance/attendance_event.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshProfile();
    _refreshDashboard();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      _refreshDashboard();
    }
  }

  void _refreshProfile() {
    context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
  }

  Future<void> _navigateToProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
    // Refresh dashboard data when returning from profile
    if (mounted) {
      _refreshDashboard();
    }
  }

  void _refreshDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
            AttendanceTodayRequested(employeeId: authState.user.id),
          );
      context.read<AttendanceBloc>().add(
            AttendanceDashboardRequested(employeeId: authState.user.id),
          );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        } else if (state is AuthAuthenticated) {
          // Also refresh dashboard data now that we have the user
          _refreshDashboard();
        }
      },
      child: Scaffold(
        body: DashboardPage(onNavigateToProfile: _navigateToProfile),
      ),
    );
  }
}
