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
    );
  }
}
