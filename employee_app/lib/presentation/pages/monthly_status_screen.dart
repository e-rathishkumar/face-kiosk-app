import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

class MonthlyStatusScreen extends StatelessWidget {
  final String title;
  final List<dynamic> dates;

  const MonthlyStatusScreen({
    super.key,
    required this.title,
    required this.dates,
  });

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
          '$title Dates',
          style: AppTypography.h4.copyWith(color: AppTheme.textPrimary),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: dates.isEmpty
            ? Center(
                child: Text(
                  'No dates found',
                  style: AppTypography.bodyMedium.copyWith(color: AppTheme.textSecondary),
                ),
              )
            : ListView.separated(
                itemCount: dates.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  IconData iconData;
                  Color iconColor;
                  
                  if (title.toLowerCase() == 'present') {
                    iconData = Icons.check_circle_outline;
                    iconColor = AppTheme.successColor;
                  } else if (title.toLowerCase() == 'absent') {
                    iconData = Icons.event_busy;
                    iconColor = AppTheme.errorColor;
                  } else {
                    iconData = Icons.access_time;
                    iconColor = AppTheme.warningColor;
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
                      dates[index].toString(),
                      style: AppTypography.labelLarge.copyWith(color: AppTheme.textPrimary),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        'Status: $title',
                        style: AppTypography.caption,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
