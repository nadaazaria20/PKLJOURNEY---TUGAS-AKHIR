import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({
    super.key,
    required this.students,
    required this.attendanceRecords,
    this.isIduka = false,
    this.idukaName,
    this.onApproveAttendance,
  });

  final List<PklUser> students;
  final Map<String, List<AttendanceRecord>> attendanceRecords;

  /// Jika true, tampilkan tombol Setujui / Tolak (khusus Pembimbing IDUKA).
  final bool isIduka;
  final String? idukaName;

  /// Callback: (studentAccountId, recordDate, approve)
  final void Function(String studentAccountId, DateTime recordDate, bool approve)?
      onApproveAttendance;

  void _showDetail(BuildContext context, PklUser student, AttendanceRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AttendanceDetailSheet(
        student: student,
        record: record,
        isIduka: isIduka,
        idukaName: idukaName,
        onApprove: onApproveAttendance == null
            ? null
            : (approve) {
                onApproveAttendance!(student.accountId, record.date, approve);
                Navigator.pop(sheetContext);
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: isIduka ? 'Konfirmasi Presensi' : 'Riwayat kehadiran',
            subtitle: isIduka
                ? 'Setujui atau tolak presensi siswa PKL di perusahaan Anda.'
                : 'Presensi murid yang menjadi tanggung jawab Anda.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoPill(
                  label: '${students.length} murid',
                  color: AppColors.cream,
                  textColor: AppColors.maroon,
                  icon: Icons.groups_2_outlined,
                ),
                if (isIduka) ...[
                  const SizedBox(width: 6),
                  const PklNotificationButton(unreadCount: 2),
                ],
              ],
            ),
          ),
          if (isIduka)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paleAmber,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cream),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ketuk baris presensi untuk melihat detail dan memberikan konfirmasi kehadiran.',
                      style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (students.isEmpty)
            const WhiteCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.maroon,
                      size: 38,
                    ),
                    SizedBox(height: 11),
                    Text(
                      'Belum ada murid bimbingan',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tambahkan atau tautkan murid terlebih dahulu untuk melihat riwayat kehadirannya.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...students.map((student) {
              final records = List<AttendanceRecord>.of(
                attendanceRecords[student.accountId] ?? const [],
              )..sort((a, b) => b.date.compareTo(a.date));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WhiteCard(
                  padding: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.cream,
                              child: Text(
                                student.name.isEmpty
                                    ? '?'
                                    : student.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'NISN ${student.accountId}',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InfoPill(
                              label: '${records.length} hari',
                              color: AppColors.paleGreen,
                              textColor: AppColors.green,
                              icon: Icons.calendar_month_outlined,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 15, endIndent: 15),
                      if (records.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Belum ada riwayat presensi.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                      else
                        ...records.take(10).map(
                              (record) => _StudentAttendanceRow(
                                record: record,
                                isIduka: isIduka,
                                onTap: () => _showDetail(context, student, record),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Row ───────────────────────────────────────────────────────────────────────

class _StudentAttendanceRow extends StatelessWidget {
  const _StudentAttendanceRow({
    required this.record,
    required this.onTap,
    this.isIduka = false,
  });

  final AttendanceRecord record;
  final VoidCallback onTap;
  final bool isIduka;

  @override
  Widget build(BuildContext context) {
    final isComplete = record.checkInTime != null && record.checkOutTime != null;

    // Warna badge status IDUKA
    Color statusColor;
    IconData statusIcon;
    if (isIduka) {
      if (record.isApprovedByIduka) {
        statusColor = AppColors.green;
        statusIcon = Icons.verified_rounded;
      } else {
        statusColor = AppColors.amber;
        statusIcon = Icons.pending_actions_rounded;
      }
    } else {
      statusColor = isComplete ? AppColors.green : AppColors.amber;
      statusIcon = isComplete ? Icons.check_circle_rounded : Icons.schedule_rounded;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.shortWeekday,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.shortDate,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _AttendanceTime(label: 'Masuk', value: record.checkInTime),
            const SizedBox(width: 16),
            _AttendanceTime(label: 'Pulang', value: record.checkOutTime),
            const SizedBox(width: 10),
            Icon(statusIcon, color: statusColor, size: 17),
            if (isIduka) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Detail Sheet ──────────────────────────────────────────────────────────────

class _AttendanceDetailSheet extends StatelessWidget {
  const _AttendanceDetailSheet({
    required this.student,
    required this.record,
    this.isIduka = false,
    this.idukaName,
    this.onApprove,
  });

  final PklUser student;
  final AttendanceRecord record;
  final bool isIduka;
  final String? idukaName;
  final void Function(bool approve)? onApprove;

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeLabel =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')} WIB';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.cream,
                    child: Text(
                      student.name.isEmpty ? '?' : student.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                        Text('NISN ${student.accountId}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: record.isApprovedByIduka
                          ? AppColors.paleGreen
                          : AppColors.paleAmber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.isApprovedByIduka ? 'Disetujui' : 'Menunggu',
                      style: TextStyle(
                        color: record.isApprovedByIduka
                            ? AppColors.green
                            : AppColors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Info presensi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.calendar_today_rounded, AppColors.maroon,
                        'Tanggal', '${record.shortWeekday}, ${record.shortDate}'),
                    _infoRow(Icons.login_rounded, AppColors.green,
                        'Jam Masuk', record.checkInTime != null ? '${record.checkInTime} WIB' : '-'),
                    _infoRow(Icons.logout_rounded, AppColors.amber,
                        'Jam Pulang', record.checkOutTime != null ? '${record.checkOutTime} WIB' : 'Belum presensi pulang'),
                    if (record.isApprovedByIduka && record.idukaApproverName != null) ...[
                      const Divider(height: 16),
                      _infoRow(Icons.verified_rounded, AppColors.green,
                          'Dikonfirmasi oleh', record.idukaApproverName!),
                      if (record.idukaApprovalTime != null)
                        _infoRow(Icons.access_time_rounded, AppColors.green,
                            'Waktu konfirmasi', record.idukaApprovalTime!),
                    ],
                  ],
                ),
              ),

              // Foto bukti
              if (record.checkInPhoto != null) ...[
                const SizedBox(height: 14),
                const Text('FOTO PRESENSI MASUK',
                    style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                PklPhotoThumbnail(
                  imageUrl: record.checkInPhoto!,
                  height: 130,
                  caption: 'Foto Presensi Masuk',
                ),
              ],
              if (record.checkOutPhoto != null) ...[
                const SizedBox(height: 10),
                const Text('FOTO PRESENSI PULANG',
                    style: TextStyle(
                        color: AppColors.taupe,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 6),
                PklPhotoThumbnail(
                  imageUrl: record.checkOutPhoto!,
                  height: 130,
                  caption: 'Foto Presensi Pulang',
                ),
              ],

              // Tombol aksi (hanya IDUKA)
              if (isIduka && onApprove != null) ...[
                const SizedBox(height: 22),
                if (!record.isApprovedByIduka) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onApprove!(false),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Tolak'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => onApprove!(true),
                          icon: const Icon(Icons.verified_rounded, size: 18),
                          label: const Text('Setujui Kehadiran'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Sudah disetujui — bisa dibatalkan
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => onApprove!(false),
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('Batalkan Persetujuan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ] else if (!isIduka) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Time Widget ───────────────────────────────────────────────────────────────

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 9),
        ),
        const SizedBox(height: 3),
        Text(
          value ?? '--.--',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}