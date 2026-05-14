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

class Application {
  final String id;
  final String userId;
  final String moduleId;
  final String levelId;
  final int yearOfStudy;
  final String motivation;
  final String? experience;
  final String? availability;
  final String? moduleId2;
  final String? levelId2;
  final bool isEligible;
  final String supportingDocPath;
  final String status;
  final String? adminNotes;
  final String? moduleCode;
  final String? moduleName;
  final String? levelName;
  final String? module2Code;
  final String? module2Name;
  final String? level2Name;

  const Application({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.levelId,
    required this.yearOfStudy,
    required this.motivation,
    this.experience,
    this.availability,
    this.moduleId2,
    this.levelId2,
    required this.isEligible,
    required this.supportingDocPath,
    required this.status,
    this.adminNotes,
    this.moduleCode,
    this.moduleName,
    this.levelName,
    this.module2Code,
    this.module2Name,
    this.level2Name,
  });

  factory Application.fromMap(Map<String, dynamic> map) {
    final module = map['modules'] as Map<String, dynamic>?;
    final level = map['levels'] as Map<String, dynamic>?;
    final module2 = map['modules2'] as Map<String, dynamic>?;
    final level2 = map['levels2'] as Map<String, dynamic>?;

    return Application(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      moduleId: map['module_id'] as String,
      levelId: map['level_id'] as String,
      yearOfStudy: (map['year_of_study'] as int?) ?? 1,
      motivation: map['motivation'] as String,
      experience: map['experience'] as String?,
      availability: map['availability'] as String?,
      moduleId2: map['module_id_2'] as String?,
      levelId2: map['level_id_2'] as String?,
      isEligible: (map['is_eligible'] as bool?) ?? false,
      supportingDocPath: (map['supporting_doc_path'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'submitted',
      adminNotes: map['admin_notes'] as String?,
      moduleCode: module?['code'] as String?,
      moduleName: module?['name'] as String?,
      levelName: level?['name'] as String?,
      module2Code: module2?['code'] as String?,
      module2Name: module2?['name'] as String?,
      level2Name: level2?['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'level_id': levelId,
      'year_of_study': yearOfStudy,
      'motivation': motivation,
      'experience': experience,
      'availability': availability,
      'module_id_2': moduleId2,
      'level_id_2': levelId2,
      'is_eligible': isEligible,
      'supporting_doc_path': supportingDocPath,
      'status': status,
      'admin_notes': adminNotes,
    };
  }
}
