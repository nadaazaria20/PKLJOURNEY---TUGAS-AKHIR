// lib/services/location_repository.dart

import '../models/internship_location.dart';
import 'supabase_service.dart';

class LocationRepository {
  static const _table = 'internship_locations';

  Future<Map<String, InternshipLocation>> fetchAll() async {
    final rows = await supabase.from(_table).select();
    final Map<String, InternshipLocation> map = {};
    for (final row in rows) {
      final teacherId = row['teacher_account_id'] as String;
      map[teacherId] = InternshipLocation.fromJson(row);
    }
    return map;
  }

  Future<void> save(String teacherAccountId, InternshipLocation location) async {
    await supabase.from(_table).upsert(
          location.toJson(teacherAccountId: teacherAccountId),
          onConflict: 'teacher_account_id',
        );
  }
}
