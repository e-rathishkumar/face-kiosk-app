import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/constants/string_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/activity_record.dart';
import '../blocs/attendance/attendance_bloc.dart';
import '../blocs/attendance/attendance_event.dart';
import '../blocs/attendance/attendance_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'recent_activities_screen.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onNavigateToProfile;

  const DashboardPage({
    super.key,
    required this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<AttendanceBloc>().add(
                    AttendanceTodayRequested(employeeId: authState.user.id),
                  );
              context.read<AttendanceBloc>().add(
                    AttendanceDashboardRequested(employeeId: authState.user.id),
                  );
            }
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(context),
                      SizedBox(height: 24.h),
                      _buildTodayStatusCard(context),
                      SizedBox(height: 24.h),
                      _buildMonthlySummary(context),
                      SizedBox(height: 24.h),
                      _buildActivityLog(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: AppTheme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            Strings.dashboard,
            style: AppTypography.h4.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            return GestureDetector(
              onTap: onNavigateToProfile,
              child: Container(
                margin: EdgeInsets.only(right: 24.w),
                child: user?.profilePhotoUrl != null
                    ? CircleAvatar(
                        radius: 18.r,
                        backgroundImage: NetworkImage(user!.profilePhotoUrl!),
                      )
                    : CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          user?.firstName.isNotEmpty == true
                              ? user!.firstName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated
            ? state.user.firstName
            : 'Employee';
        
        // Simple time-based greeting
        final hour = DateTime.now().hour;
        String greeting = 'Good Evening';
        if (hour < 12) {
          greeting = 'Good Morning';
        } else if (hour < 17) {
          greeting = 'Good Afternoon';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '$name 👋',
              style: AppTypography.h2.copyWith(color: AppTheme.textPrimary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodayStatusCard(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        final record = state is AttendanceLoaded ? state.todayRecord : null;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.todayStatus,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeWidget(
                      'Check In',
                      record?.checkIn,
                      Icons.login_rounded,
                      Colors.greenAccent,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40.h,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildTimeWidget(
                      'Check Out',
                      record?.checkOut,
                      Icons.logout_rounded,
                      Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Center(
                child: Builder(
                  builder: (context) {
                    final dashData = state is AttendanceLoaded ? state.dashboardData : null;
                    final totalHours = dashData?['total_hours_today'] ?? 0.0;
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Total Hours: ${totalHours.toStringAsFixed(1)} hrs',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeWidget(
    String label,
    DateTime? time,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          time != null ? DateFormat('hh:mm a').format(time) : '--:--',
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }



  Widget _buildMonthlySummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.thisMonth,
          style: AppTypography.h4.copyWith(color: AppTheme.textPrimary),
        ),
        SizedBox(height: 16.h),
        BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            final dashData = state is AttendanceLoaded ? state.dashboardData : null;
            // Provide some default dummy data if dashboard fetch fails or is loading
            final present = dashData?['present_today'] ?? 21;
            final absent = dashData?['absent_today'] ?? 2;
            final late = dashData?['late_today'] ?? 1;

            void showDatesBottomSheet(String title, List<dynamic> dates) {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$title Dates',
                          style: AppTypography.h3.copyWith(color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 16.h),
                        if (dates.isEmpty)
                          Text(
                            'No dates found',
                            style: AppTypography.bodyMedium.copyWith(color: AppTheme.textSecondary),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: dates.length,
                              separatorBuilder: (_, __) => SizedBox(height: 8.h),
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppTheme.dividerColor),
                                  ),
                                  child: Text(
                                    dates[index].toString(),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.present,
                    value: present.toString(),
                    icon: Icons.check_circle_outline,
                    color: AppTheme.successColor,
                    onTap: () => showDatesBottomSheet(Strings.present, dashData?['present_dates'] ?? []),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.absent,
                    value: absent.toString(),
                    icon: Icons.event_busy,
                    color: AppTheme.errorColor,
                    onTap: () => showDatesBottomSheet(Strings.absent, dashData?['absent_dates'] ?? []),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.late,
                    value: late.toString(),
                    icon: Icons.access_time,
                    color: AppTheme.warningColor,
                    onTap: () => showDatesBottomSheet(Strings.late, dashData?['late_dates'] ?? []),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTypography.caption,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActivityLog(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.recentActivity,
              style: AppTypography.h4.copyWith(color: AppTheme.textPrimary),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecentActivitiesScreen()),
                );
              },
              child: Text(
                Strings.viewAll,
                style: AppTypography.buttonSmall.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AttendanceLoaded) {
              final activities = state.activities.take(3).toList();
              if (activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      'No recent activities',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 28.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityItem(activity);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(ActivityRecord activity) {
    final dateStr = DateFormat('MMM dd, yyyy').format(activity.timestamp);
    final timeStr = DateFormat('hh:mm a').format(activity.timestamp);

    IconData iconData;
    Color iconColor;
    String subtitleText;

    if (activity.type == 'CHECK_IN') {
      iconData = Icons.login;
      iconColor = AppTheme.successColor;
      subtitleText = 'Check In at $timeStr';
    } else if (activity.type == 'CHECK_OUT') {
      iconData = Icons.logout;
      iconColor = AppTheme.warningColor;
      subtitleText = 'Check Out at $timeStr';
    } else {
      iconData = Icons.face_retouching_natural;
      iconColor = AppTheme.primaryColor;
      subtitleText = 'Detected at $timeStr';
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor,
            size: 24.sp,
          ),
        ),
      ),
      title: Text(
        dateStr,
        style: AppTypography.labelLarge.copyWith(color: AppTheme.textPrimary),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          subtitleText,
          style: AppTypography.caption,
        ),
      ),
      trailing: activity.status != null
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: activity.status == 'ACTIVE' || activity.status == 'PRESENT'
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                activity.status!,
                style: AppTypography.labelSmall.copyWith(
                  color: activity.status == 'ACTIVE' || activity.status == 'PRESENT'
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }
}
