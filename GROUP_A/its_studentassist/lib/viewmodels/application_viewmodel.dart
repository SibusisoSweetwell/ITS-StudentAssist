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

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/application.dart';
import '../services/supabase_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> submitApplication({
    required String moduleId,
    required String levelId,
    required int yearOfStudy,
    required String motivation,
    String? experience,
    String? availability,
    String? moduleId2,
    String? levelId2,
    required bool isEligible,
    required Uint8List supportingDocBytes,
    required String supportingDocName,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        errorMessage = 'User is not logged in.';
        return false;
      }

      final safeName = supportingDocName.replaceAll(' ', '_');
      final storagePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await SupabaseService.client.storage
          .from('supporting-docs')
          .uploadBinary(
            storagePath,
            supportingDocBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final payload = <String, dynamic>{
        'module_id': moduleId,
        'level_id': levelId,
        'year_of_study': yearOfStudy,
        'motivation': motivation,
        'experience': experience,
        'availability': availability,
        'module_id_2': moduleId2,
        'level_id_2': levelId2,
        'is_eligible': isEligible,
        'supporting_doc_path': storagePath,
        'status': 'submitted',
      };

      final existingRows = await SupabaseService.client
          .from('applications')
          .select('id,status')
          .eq('user_id', userId)
          .limit(1);

      if (existingRows.isNotEmpty) {
        final existing = existingRows.first;
        final existingStatus = existing['status'] as String? ?? 'submitted';
        if (existingStatus != 'submitted') {
          errorMessage =
              'Application is already $existingStatus and cannot be resubmitted.';
          return false;
        }

        await SupabaseService.client
            .from('applications')
            .update(payload)
            .eq('id', existing['id'] as String);
      } else {
        await SupabaseService.client.from('applications').insert({
          'user_id': userId,
          ...payload,
        });
      }

      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Application?> fetchCurrentUserApplication() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await SupabaseService.client
        .from('applications')
        .select(
          'id,user_id,module_id,level_id,year_of_study,module_id_2,level_id_2,'
          'is_eligible,supporting_doc_path,motivation,experience,availability,'
          'status,admin_notes,created_at,updated_at,'
          'modules!applications_module_id_fkey(code,name),'
          'levels!applications_level_id_fkey(name),'
          'modules2:modules!applications_module_id_2_fkey(code,name),'
          'levels2:levels!applications_level_id_2_fkey(name)',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1);

    final rows = response as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }

    return Application.fromMap(rows.first as Map<String, dynamic>);
  }

  Future<bool> updateApplication({
    required String applicationId,
    required String moduleId,
    required String levelId,
    required int yearOfStudy,
    required String motivation,
    String? experience,
    String? availability,
    String? moduleId2,
    String? levelId2,
    required bool isEligible,
    Uint8List? supportingDocBytes,
    String? supportingDocName,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? storagePath;
      if (supportingDocBytes != null && supportingDocName != null) {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId == null) {
          errorMessage = 'User is not logged in.';
          return false;
        }

        final safeName = supportingDocName.replaceAll(' ', '_');
        storagePath =
            '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

        await SupabaseService.client.storage
            .from('supporting-docs')
            .uploadBinary(
              storagePath,
              supportingDocBytes,
              fileOptions: const FileOptions(upsert: true),
            );
      }

      final updatePayload = <String, dynamic>{
        'module_id': moduleId,
        'level_id': levelId,
        'year_of_study': yearOfStudy,
        'motivation': motivation,
        'experience': experience,
        'availability': availability,
        'module_id_2': moduleId2,
        'level_id_2': levelId2,
        'is_eligible': isEligible,
      };

      if (storagePath != null) {
        updatePayload['supporting_doc_path'] = storagePath;
      }

      await SupabaseService.client
          .from('applications')
          .update(updatePayload)
          .eq('id', applicationId);

      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteApplication({
    required String applicationId,
    String? supportingDocPath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (supportingDocPath != null && supportingDocPath.isNotEmpty) {
        await SupabaseService.client.storage.from('supporting-docs').remove([
          supportingDocPath,
        ]);
      }
      await SupabaseService.client
          .from('applications')
          .delete()
          .eq('id', applicationId);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
