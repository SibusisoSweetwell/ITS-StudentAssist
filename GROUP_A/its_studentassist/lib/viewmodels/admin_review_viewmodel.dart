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

import '../models/admin_application.dart';
import '../services/supabase_service.dart';

class AdminReviewViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<AdminApplication> applications = [];

  Future<void> fetchApplications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        errorMessage = 'Please log in to view applications.';
        return;
      }

      final response = await SupabaseService.client
          .from('applications')
          .select(
            'id,user_id,module_id,level_id,year_of_study,module_id_2,level_id_2,'
            'is_eligible,supporting_doc_path,status,admin_notes,reviewed_by,'
            'motivation,experience,availability,created_at,'
            'profiles(full_name,student_number,email),'
            'modules!applications_module_id_fkey(code,name),'
            'levels!applications_level_id_fkey(name),'
            'modules2:modules!applications_module_id_2_fkey(code,name),'
            'levels2:levels!applications_level_id_2_fkey(name)',
          )
          .order('created_at', ascending: false);

      applications = (response as List<dynamic>)
          .map((item) => AdminApplication.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      errorMessage = error.toString();

      // Fallback without embedded relations if join fails.
      try {
        final response = await SupabaseService.client
            .from('applications')
            .select()
            .order('created_at', ascending: false);

        applications = (response as List<dynamic>)
            .map(
              (item) => AdminApplication.fromMap(item as Map<String, dynamic>),
            )
            .toList();
      } catch (_) {
        // Keep the original error message.
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String applicationId,
    required String status,
    String? adminNotes,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final reviewerId = SupabaseService.client.auth.currentUser?.id;
      await SupabaseService.client
          .from('applications')
          .update({
            'status': status,
            'admin_notes': adminNotes,
            'reviewed_by': reviewerId,
          })
          .eq('id', applicationId);

      await fetchApplications();

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

      await fetchApplications();

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
