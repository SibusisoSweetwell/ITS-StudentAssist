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

import '../models/level.dart';
import '../models/module.dart';
import '../services/supabase_service.dart';

class ReferenceDataViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Module> modules = [];
  List<Level> levels = [];

  Future<void> loadReferenceData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final modulesResponse = await SupabaseService.client
          .from('modules')
          .select()
          .order('code', ascending: true);
      final levelsResponse = await SupabaseService.client
          .from('levels')
          .select()
          .order('name', ascending: true);

      modules = (modulesResponse as List<dynamic>)
          .map((item) => Module.fromMap(item as Map<String, dynamic>))
          .toList();
      levels = (levelsResponse as List<dynamic>)
          .map((item) => Level.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
