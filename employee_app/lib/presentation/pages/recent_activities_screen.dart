import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/activity_record.dart';
import '../blocs/attendance/attendance_bloc.dart';
import '../blocs/attendance/attendance_state.dart';

class RecentActivitiesScreen extends StatelessWidget {
  const RecentActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recent Activities',
          style: AppTypography.h4.copyWith(color: AppTheme.textPrimary),
        ),
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceLoaded) {
            final activities = state.activities;
            if (activities.isEmpty) {
              return Center(
                child: Text(
                  'No recent activities',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(24.w),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(activity);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
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
