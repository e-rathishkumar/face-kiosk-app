import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/constants/string_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/attendance_record.dart';
import '../blocs/attendance/attendance_bloc.dart';
import '../blocs/attendance/attendance_event.dart';
import '../blocs/attendance/attendance_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

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
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
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
                    color: Colors.white.withValues(alpha: 0.2),
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
              // SizedBox(height: 24.h),
              // _buildActionButtons(context, record, isLoading),
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
            color: Colors.white.withValues(alpha: 0.7),
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

            return Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.present,
                    value: present.toString(),
                    icon: Icons.check_circle_outline,
                    color: AppTheme.successColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.absent,
                    value: absent.toString(),
                    icon: Icons.cancel_outlined,
                    color: AppTheme.errorColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSummaryCard(
                    title: Strings.late,
                    value: late.toString(),
                    icon: Icons.access_time,
                    color: AppTheme.warningColor,
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
  }) {
    return Container(
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
              color: color.withValues(alpha: 0.1),
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
              onPressed: () {},
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
              final records = state.records.take(5).toList();
              if (records.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      Strings.noAttendanceRecords,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildActivityItem(record);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(AttendanceRecord record) {
    final dateStr = record.checkIn != null 
        ? DateFormat('MMM dd, yyyy').format(record.checkIn!)
        : 'Unknown Date';
        
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Icon(
            Icons.history,
            color: AppTheme.primaryColor,
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
        child: Row(
          children: [
            Icon(Icons.login, size: 14.sp, color: AppTheme.successColor),
            SizedBox(width: 4.w),
            Text(
              record.checkIn != null ? DateFormat('hh:mm a').format(record.checkIn!) : '--:--',
              style: AppTypography.caption,
            ),
            SizedBox(width: 12.w),
            Icon(Icons.logout, size: 14.sp, color: AppTheme.warningColor),
            SizedBox(width: 4.w),
            Text(
              record.checkOut != null ? DateFormat('hh:mm a').format(record.checkOut!) : '--:--',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: record.status == 'PRESENT' 
              ? AppTheme.successColor.withValues(alpha: 0.1)
              : AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          record.status ?? 'Present',
          style: AppTypography.labelSmall.copyWith(
            color: record.status == 'PRESENT' ? AppTheme.successColor : AppTheme.warningColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
