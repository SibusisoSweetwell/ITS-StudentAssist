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

import '../models/profile.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentNumber,
    String role = 'student',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'student_number': studentNumber,
          'role': role,
        },
      );

      final userId = response.user?.id;
      if (userId != null) {
        await SupabaseService.client.from('profiles').insert({
          'user_id': userId,
          'full_name': fullName,
          'student_number': studentNumber,
          'email': email,
          'role': role,
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

  Future<Profile?> fetchCurrentUserProfile() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('user_id,full_name,student_number,email,role')
          .eq('user_id', userId)
          .single();
      return Profile.fromMap(response);
    } catch (_) {
      return null;
    }
  }

  Future<String?> fetchCurrentUserRole() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('role')
          .eq('user_id', userId)
          .single();
      return response['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String studentNumber,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      errorMessage = 'You must be logged in to update your profile.';
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await SupabaseService.client
          .from('profiles')
          .update({'full_name': fullName, 'student_number': studentNumber})
          .eq('user_id', userId);
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
