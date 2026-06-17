import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  // Headings
  static TextStyle get h1 => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get h4 => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLarge => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // Caption
  static TextStyle get caption => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: const Color(0xFF6B7280),
      );

  // Button
  static TextStyle get button => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
