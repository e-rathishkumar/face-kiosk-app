import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? department;
  final String? designation;
  final bool isActive;
  final String? profilePhotoUrl;
  final String? gender;
  final bool isNewUser;
  final bool faceRegistered;
  final DateTime joinedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.department,
    this.designation,
    this.isActive = true,
    this.profilePhotoUrl,
    this.gender,
    this.isNewUser = false,
    this.faceRegistered = false,
    required this.joinedAt,
  });

  String get name => '$firstName $lastName';
  String get employeeId => employeeCode;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      gender: json['gender']?.toString(),
      isNewUser: json['must_reset_password'] as bool? ?? json['is_new_user'] as bool? ?? false,
      faceRegistered: json['face_registered'] as bool? ?? true,
      joinedAt: json['joining_date'] != null
          ? DateTime.tryParse(json['joining_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_code': employeeCode,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'department': department,
        'designation': designation,
        'is_active': isActive,
        'profile_photo_url': profilePhotoUrl,
        'gender': gender,
        'is_new_user': isNewUser,
        'face_registered': faceRegistered,
        'joining_date': joinedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, employeeCode, firstName, lastName];
}
