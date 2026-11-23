import 'package:flutter/material.dart';
import 'models/attendance_record.dart';
import 'models/internship_location.dart';
import 'models/journal_entry.dart';
import 'models/pkl_user.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/attendance_repostitory.dart';
import 'services/journal_repository.dart';
import 'services/location_repository.dart';
import 'services/supabase_service.dart';
import 'services/user_repository.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const PklJourneyApp());
}

class PklJourneyApp extends StatefulWidget {
  const PklJourneyApp({super.key});

  @override
  State<PklJourneyApp> createState() => _PklJourneyAppState();
}

class _PklJourneyAppState extends State<PklJourneyApp> {
  final _userRepo = UserRepository();
  final _attendanceRepo = AttendanceRepository();
  final _journalRepo = JournalRepository();
  final _locationRepo = LocationRepository();

  bool _showSplash = true;
  PklUser? _currentUser;
  List<PklUser> _users = createDemoUsers();
  final Map<String, InternshipLocation> _teacherLocations = {
    '19820109940201': const InternshipLocation(
      companyName: 'PT Aksara Digital Nusantara',
      address:
          'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
      latitude: -6.2146,
      longitude: 106.8189,
      radiusMeters: 50,
    ),
  };
  final Map<String, List<AttendanceRecord>> _attendanceRecords = {
    '007812121134': [
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 1)),
        checkInTime: '07.50',
        checkOutTime: '16.05',
        checkInPhoto: PklPhotoPresets.coding,
        checkOutPhoto: PklPhotoPresets.report,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.15 WIB',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 2)),
        checkInTime: '07.45',
        checkOutTime: '16.10',
        checkInPhoto: PklPhotoPresets.meeting,
        checkOutPhoto: PklPhotoPresets.report,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.20 WIB',
      ),
      AttendanceRecord(
        date: DateTime.now().subtract(const Duration(days: 3)),
        checkInTime: '07.55',
        checkOutTime: '16.00',
        checkInPhoto: PklPhotoPresets.networking,
        checkOutPhoto: PklPhotoPresets.report,
        isApprovedByIduka: true,
        idukaApproverName: 'Hendro Prasetyo, S.T.',
        idukaApprovalTime: '16.10 WIB',
      ),
    ],
  };
  final Map<String, List<JournalEntry>> _journalEntries = {
    '007812121134': [
      JournalEntry(
        id: 'demo-workplace-orientation',
        title: 'Orientasi Lingkungan Kerja & Setup Tools',
        description:
            'Mengenal tim engineering, alur kerja agile scrum, dan setup environment Flutter & Git di divisi teknologi informasi.',
        date: '18 Nov 2026',
        time: '15.42',
        tag: 'Orientasi',
        isReviewed: true,
        imageUrl: PklPhotoPresets.meeting,
        teacherNote:
            'Laporan awal orientasi sangat baik dan lengkap. Lanjutkan komunikasi yang aktif dengan mentor industri!',
      ),
      JournalEntry(
        id: 'demo-git-collaboration',
        title: 'Pembuatan Komponen UI & Slicing Figma',
        description:
            'Mengimplementasikan desain sistem ke dalam widget Flutter, membuat reusable card, dan pull request ke branch dev.',
        date: '19 Nov 2026',
        time: '16.05',
        tag: 'Proyek',
        isReviewed: false,
        imageUrl: PklPhotoPresets.coding,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSupabaseData();
  }

  Future<void> _loadSupabaseData() async {
    if (!isSupabaseReady) return;
    try {
      final remoteUsers = await _userRepo.fetchAll();
      if (remoteUsers.isNotEmpty && mounted) {
        setState(() => _users = remoteUsers);
      }

      final studentIds = _users
          .where((u) => u.role == UserRole.murid)
          .map((u) => u.accountId)
          .toList();

      if (studentIds.isNotEmpty) {
        final remoteAttendance = await _attendanceRepo.fetchForStudents(studentIds);
        final remoteJournals = await _journalRepo.fetchForStudents(studentIds);
        final remoteLocations = await _locationRepo.fetchAll();

        if (mounted) {
          setState(() {
            _attendanceRecords.addAll(remoteAttendance);
            _journalEntries.addAll(remoteJournals);
            _teacherLocations.addAll(remoteLocations);
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error sinkronisasi Supabase: $e');
    }
  }

  void _finishSplash() {
    if (mounted) setState(() => _showSplash = false);
  }

  void _login(PklUser user) {
    setState(() => _currentUser = user);
  }

  void _registerAccount(PklUser user) {
    setState(() => _users.add(user));
    if (isSupabaseReady) {
      _userRepo.insert(user).catchError((e) {
        debugPrint('Gagal menyimpan user ke Supabase: $e');
        return user;
      });
    }
  }

  void _addTeacherStudent(PklUser teacher, PklUser student) {
    setState(() {
      final existingIndex = _users.indexWhere(
        (user) =>
            user.role == UserRole.murid &&
            user.accountId == student.accountId,
      );
      if (existingIndex == -1) {
        _users.add(student.copyWith(mentorAccountId: teacher.accountId));
      } else {
        _users[existingIndex] =
            _users[existingIndex].copyWith(mentorAccountId: teacher.accountId);
      }
    });
    if (isSupabaseReady) {
      _userRepo.assignMentor(student.accountId, teacher.accountId).catchError((e) {
        debugPrint('Gagal assign mentor ke Supabase: $e');
      });
    }
  }

  void _assignStudentMentor(String studentAccountId, String? teacherAccountId) {
    setState(() {
      final index = _users.indexWhere(
        (user) =>
            user.role == UserRole.murid && user.accountId == studentAccountId,
      );
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          mentorAccountId: teacherAccountId,
          clearMentorAccountId: teacherAccountId == null,
        );
      }
    });
    if (isSupabaseReady) {
      _userRepo.assignMentor(studentAccountId, teacherAccountId).catchError((e) {
        debugPrint('Gagal assign mentor ke Supabase: $e');
      });
    }
  }

  void _saveTeacherLocation(String teacherAccountId, InternshipLocation location) {
    setState(() => _teacherLocations[teacherAccountId] = location);
    if (isSupabaseReady) {
      _locationRepo.save(teacherAccountId, location).catchError((e) {
        debugPrint('Gagal menyimpan lokasi ke Supabase: $e');
      });
    }
  }

  void _saveAttendance(
    String studentAccountId,
    List<AttendanceRecord> records,
  ) {
    setState(() => _attendanceRecords[studentAccountId] = records);
    if (isSupabaseReady) {
      _attendanceRepo.saveAll(studentAccountId, records).catchError((e) {
        debugPrint('Gagal menyimpan presensi ke Supabase: $e');
      });
    }
  }

  void _addJournalEntry(String studentAccountId, JournalEntry entry) {
    setState(() {
      _journalEntries[studentAccountId] = [
        entry,
        ...(_journalEntries[studentAccountId] ?? const <JournalEntry>[]),
      ];
    });
    if (isSupabaseReady) {
      _journalRepo.insert(studentAccountId, entry).then((created) {
        // update demo id with real supabase id
        final list = _journalEntries[studentAccountId];
        if (list != null) {
          final idx = list.indexOf(entry);
          if (idx != -1 && mounted) {
            setState(() => list[idx] = created);
          }
        }
      }).catchError((e) {
        debugPrint('Gagal menyimpan jurnal ke Supabase: $e');
        return entry;
      });
    }
  }

  void _markJournalReviewed(String studentAccountId, String entryId,
      {String? teacherNote}) {
    final entries = _journalEntries[studentAccountId];
    if (entries == null) return;
    final index = entries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) return;
    setState(() => entries[index] = entries[index].copyWith(
          isReviewed: true,
          teacherNote: teacherNote ??
              entries[index].teacherNote ??
              'Kegiatan PKL telah diperiksa dan disetujui pembimbing.',
        ));
    if (isSupabaseReady) {
      _journalRepo.markReviewed(studentAccountId, entryId, teacherNote: teacherNote).catchError((e) {
        debugPrint('Gagal mark review jurnal ke Supabase: $e');
      });
    }
  }

  void _deleteAccount(PklUser account) {
    setState(() {
      _users.removeWhere(
        (user) =>
            user.role == account.role && user.accountId == account.accountId,
      );

      if (account.role == UserRole.guru) {
        for (var index = 0; index < _users.length; index++) {
          if (_users[index].mentorAccountId == account.accountId) {
            _users[index] = _users[index].copyWith(clearMentorAccountId: true);
          }
        }
        _teacherLocations.remove(account.accountId);
      } else if (account.role == UserRole.murid) {
        _attendanceRecords.remove(account.accountId);
        _journalEntries.remove(account.accountId);
      }
    });

    if (isSupabaseReady) {
      _userRepo.delete(account.accountId, account.role.name).catchError((e) {
        debugPrint('Gagal menghapus user dari Supabase: $e');
      });
    }
  }

  void _updateUser(PklUser updatedUser) {
    setState(() {
      final index = _users.indexWhere(
        (u) =>
            u.accountId == updatedUser.accountId &&
            u.role == updatedUser.role,
      );
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_currentUser?.accountId == updatedUser.accountId &&
          _currentUser?.role == updatedUser.role) {
        _currentUser = updatedUser;
      }
    });

    if (isSupabaseReady) {
      _userRepo.update(updatedUser).catchError((e) {
        debugPrint('Gagal update user di Supabase: $e');
      });
    }
  }

  void _logout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKLJOURNEY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _showSplash
          ? SplashScreen(onFinished: _finishSplash)
          : _currentUser != null
              ? MainShell(
                  user: _currentUser!,
                  users: _users,
                  teacherLocations: _teacherLocations,
                  attendanceRecords: _attendanceRecords,
                  journalEntries: _journalEntries,
                  onRegisterAccount: _registerAccount,
                  onAddStudent: _addTeacherStudent,
                  onAssignMentor: _assignStudentMentor,
                  onSaveTeacherLocation: _saveTeacherLocation,
                  onSaveAttendance: _saveAttendance,
                  onAddJournalEntry: _addJournalEntry,
                  onMarkJournalReviewed: _markJournalReviewed,
                  onDeleteAccount: _deleteAccount,
                  onLogout: _logout,
                  onUpdateUser: _updateUser,
                )
              : LoginScreen(users: _users, onLogin: _login),
    );
  }
}