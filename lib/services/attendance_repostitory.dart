// lib/services/attendance_repository.dart

import '../models/attendance_record.dart';
import 'supabase_service.dart';

class AttendanceRepository {
  static const _table = 'attendance_records';

  // ── BACA ─────────────────────────────────────────────────
  Future<List<AttendanceRecord>> fetchByStudent(String studentAccountId) async {
    final rows = await supabase
        .from(_table)
        .select()
        .eq('student_account_id', studentAccountId)
        .order('date', ascending: false);
    return rows.map(AttendanceRecord.fromJson).toList();
  }

  /// Ambil presensi semua murid sekaligus (untuk IDUKA / Guru).
  Future<Map<String, List<AttendanceRecord>>> fetchForStudents(
      List<String> studentAccountIds) async {
    if (studentAccountIds.isEmpty) return {};

    final rows = await supabase
        .from(_table)
        .select()
        .inFilter('student_account_id', studentAccountIds)
        .order('date', ascending: false);

    final Map<String, List<AttendanceRecord>> result = {};
    for (final row in rows) {
      final key = row['student_account_id'] as String;
      result.putIfAbsent(key, () => []).add(AttendanceRecord.fromJson(row));
    }
    return result;
  }

  // ── UPSERT (insert or update berdasarkan student + date) ──
  Future<void> upsert(String studentAccountId, AttendanceRecord record) async {
    await supabase.from(_table).upsert(
      record.toJson(studentAccountId: studentAccountId),
      onConflict: 'student_account_id,date',
    );
  }

  /// Simpan seluruh daftar presensi (batch upsert).
  Future<void> saveAll(
      String studentAccountId, List<AttendanceRecord> records) async {
    if (records.isEmpty) return;
    final rows = records
        .map((r) => r.toJson(studentAccountId: studentAccountId))
        .toList();
    await supabase.from(_table).upsert(rows, onConflict: 'student_account_id,date');
  }

  // ── APPROVE / REJECT ──────────────────────────────────────
  Future<void> setApproval(
    String studentAccountId,
    DateTime date, {
    required bool approve,
    String? approverName,
    String? approvalTime,
  }) async {
    await supabase
        .from(_table)
        .update({
          'is_approved_by_iduka': approve,
          'iduka_approver_name':  approve ? approverName : null,
          'iduka_approval_time':  approve ? approvalTime : null,
          'updated_at':           DateTime.now().toIso8601String(),
        })
        .eq('student_account_id', studentAccountId)
        .eq('date', _dateStr(date));
  }

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
