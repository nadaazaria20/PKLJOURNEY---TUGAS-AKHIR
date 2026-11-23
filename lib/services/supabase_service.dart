// lib/services/supabase_service.dart
//
// Singleton wrapper untuk Supabase client.
// Ganti SUPABASE_URL dan SUPABASE_ANON_KEY dengan nilai dari:
//   Supabase Dashboard → Project Settings → API

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseConfig {
  // =========================================================================
  // ⚠️ MASUKKAN URL & ANON KEY DARI SUPABASE DASHBOARD ANDA DI SINI:
  // Supabase Dashboard -> Project Settings -> API
  // =========================================================================
  static const String url = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  static bool get isConfigured =>
      url.startsWith('https://') &&
      !url.contains('YOUR_PROJECT_ID') &&
      !url.contains('XXXXXXXX') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY') &&
      !anonKey.contains('XXXXXXXX');
}

bool _isInitialized = false;

/// Inisialisasi Supabase. Panggil di main() sebelum runApp().
/// Jika URL/Key belum diisi atau gagal, aplikasi tetap jalan menggunakan mode demo lokal.
Future<bool> initSupabase() async {
  if (!SupabaseConfig.isConfigured) {
    debugPrint('ℹ️ Supabase belum diisi URL & Anon Key. Berjalan dalam mode demo lokal.');
    return false;
  }
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _isInitialized = true;
    debugPrint('✅ Supabase berhasil terhubung.');
    return true;
  } catch (e) {
    debugPrint('⚠️ Inisialisasi Supabase gagal: $e. Fallback ke demo lokal.');
    _isInitialized = false;
    return false;
  }
}

bool get isSupabaseReady => _isInitialized;

/// Shortcut ke Supabase client global.
SupabaseClient get supabase => Supabase.instance.client;
