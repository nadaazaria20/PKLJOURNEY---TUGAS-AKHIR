// lib/services/journal_repository.dart

import '../models/journal_entry.dart';
import 'supabase_service.dart';

class JournalRepository {
  static const _table = 'journal_entries';

  // ── BACA ─────────────────────────────────────────────────
  Future<List<JournalEntry>> fetchByStudent(String studentAccountId) async {
    final rows = await supabase
        .from(_table)
        .select()
        .eq('student_account_id', studentAccountId)
        .order('created_at', ascending: false);
    return rows.map(JournalEntry.fromJson).toList();
  }

  Future<Map<String, List<JournalEntry>>> fetchForStudents(
      List<String> studentAccountIds) async {
    if (studentAccountIds.isEmpty) return {};

    final rows = await supabase
        .from(_table)
        .select()
        .inFilter('student_account_id', studentAccountIds)
        .order('created_at', ascending: false);

    final Map<String, List<JournalEntry>> result = {};
    for (final row in rows) {
      final key = row['student_account_id'] as String;
      result.putIfAbsent(key, () => []).add(JournalEntry.fromJson(row));
    }
    return result;
  }

  // ── INSERT ────────────────────────────────────────────────
  Future<JournalEntry> insert(
      String studentAccountId, JournalEntry entry) async {
    final row = await supabase
        .from(_table)
        .insert(entry.toJson(studentAccountId: studentAccountId))
        .select()
        .single();
    return JournalEntry.fromJson(row);
  }

  // ── UPDATE (review guru) ──────────────────────────────────
  Future<void> markReviewed(
    String studentAccountId,
    String entryId, {
    String? teacherNote,
  }) async {
    await supabase
        .from(_table)
        .update({
          'is_reviewed':  true,
          'teacher_note': teacherNote,
          'updated_at':   DateTime.now().toIso8601String(),
        })
        .eq('id', entryId)
        .eq('student_account_id', studentAccountId);
  }
}
