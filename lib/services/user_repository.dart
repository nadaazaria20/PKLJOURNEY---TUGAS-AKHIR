// lib/services/user_repository.dart

import '../models/pkl_user.dart';
import 'supabase_service.dart';

class UserRepository {
  static const _table = 'users';

  // ── LOGIN ─────────────────────────────────────────────────
  /// Cari user berdasarkan username + password (plain untuk demo).
  /// Di produksi gunakan Supabase Auth.
  Future<PklUser?> login(String username, String password) async {
    final rows = await supabase
        .from(_table)
        .select()
        .eq('username', username)
        .eq('password_hash', password)
        .limit(1);

    if (rows.isEmpty) return null;
    return PklUser.fromJson(rows.first);
  }

  // ── BACA ──────────────────────────────────────────────────
  Future<List<PklUser>> fetchAll() async {
    final rows = await supabase.from(_table).select().order('created_at');
    return rows.map(PklUser.fromJson).toList();
  }

  Future<PklUser?> fetchByAccountId(String accountId) async {
    final rows = await supabase
        .from(_table)
        .select()
        .eq('account_id', accountId)
        .limit(1);
    if (rows.isEmpty) return null;
    return PklUser.fromJson(rows.first);
  }

  // ── TAMBAH ────────────────────────────────────────────────
  Future<PklUser> insert(PklUser user) async {
    final row = await supabase
        .from(_table)
        .insert(user.toInsertJson())
        .select()
        .single();
    return PklUser.fromJson(row);
  }

  // ── UPDATE ────────────────────────────────────────────────
  Future<void> update(PklUser user) async {
    await supabase
        .from(_table)
        .update(user.toUpdateJson())
        .eq('account_id', user.accountId);
  }

  /// Update hanya mentor_account_id murid.
  Future<void> assignMentor(String studentAccountId, String? mentorAccountId) async {
    await supabase
        .from(_table)
        .update({'mentor_account_id': mentorAccountId})
        .eq('account_id', studentAccountId);
  }

  // ── HAPUS ────────────────────────────────────────────────
  Future<void> delete(String accountId, String role) async {
    await supabase
        .from(_table)
        .delete()
        .eq('account_id', accountId)
        .eq('role', role);
  }
}
