import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/string_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'face_capture_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  _buildPersonalInfoCard(context),
                  SizedBox(height: 24.h),
                  _buildSettingsCard(context),
                  SizedBox(height: 32.h),
                  _buildLogoutButton(context),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return SliverAppBar(
          expandedHeight: 220.h,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: user?.profilePhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.profilePhotoUrl!,
                                  width: 80.r,
                                  height: 80.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildInitialsAvatar(user),
                                ),
                              )
                            : _buildInitialsAvatar(user),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      user?.name ?? 'Employee Name',
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        user?.designation ?? 'Employee',
                        style: AppTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialsAvatar(dynamic user) {
    return Text(
      user?.firstName.isNotEmpty == true
          ? user!.firstName[0].toUpperCase()
          : 'U',
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: Strings.employeeId,
                value: user?.employeeId ?? '-',
              ),
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.business_outlined,
                label: Strings.department,
                value: user?.department ?? '-',
              ),
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: Strings.email,
                value: user?.email ?? '-',
              ),
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: Strings.phone,
                value: user?.phone ?? '-',
              ),
              const Divider(height: 1),
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: Strings.joiningDate,
                value: user != null
                    ? DateFormat('MMM dd, yyyy').format(user.joinedAt)
                    : '-',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption,
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.face,
            title: 'Register Face Data',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FaceCapturePage()),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.language,
            title: Strings.changeLanguage,
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: Strings.aboutApp,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppTheme.secondaryColor, size: 20.sp),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppTheme.textTertiary),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        icon: const Icon(Icons.logout, color: AppTheme.errorColor),
        label: Text(
          Strings.logout,
          style: AppTypography.button.copyWith(color: AppTheme.errorColor),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.errorColor),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Confirm Logout',
            style: AppTypography.h3,
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                Strings.cancel,
                style: AppTypography.buttonSmall.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                elevation: 0,
              ),
              child: Text(
                Strings.logout,
                style: AppTypography.buttonSmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.changeLanguage,
                style: AppTypography.h3,
              ),
              SizedBox(height: 24.h),
              _buildLanguageOption(Strings.english, true),
              _buildLanguageOption(Strings.tamil, false),
              _buildLanguageOption(Strings.hindi, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      title: Text(
        language,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 24.sp)
          : null,
      onTap: () {}, // Not implemented in MVP
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.fingerprint, color: Colors.white, size: 40.sp),
      ),
      children: [
        SizedBox(height: 16.h),
        Text(
          'AI-Powered Attendance Management System for employees.',
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
