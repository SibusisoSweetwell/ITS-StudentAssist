/*
Group: GROUP_A
Members:
- Sibusiso Sweetwell Masombuka - 223021992
- Sibonelo Nkosikhona Shabalala - 222086498
- Khanyile Simphiwe Chaka - 222028298
- Neo Moeketsi Motseki - 223061469
- Dan Khoza - 223062645
- Bonolo Olifant - 223016901
- Rekopantswe Molefe - 223065272
- Skhumbuzo Kgethe - 222000496
- Lesedi Setuke - 222009442
- Tshego Malope - 222017305
*/

class Profile {
  final String userId;
  final String fullName;
  final String studentNumber;
  final String email;
  final String role;

  const Profile({
    required this.userId,
    required this.fullName,
    required this.studentNumber,
    required this.email,
    required this.role,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      studentNumber: map['student_number'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'student_number': studentNumber,
      'email': email,
      'role': role,
    };
  }
}
