import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.users,
    required this.onManageAccounts,
    this.onManageMentorship,
  });

  final PklUser user;
  final List<PklUser> users;
  final VoidCallback onManageAccounts;
  final VoidCallback? onManageMentorship;

  @override
  Widget build(BuildContext context) {
    final students =
        users.where((account) => account.role == UserRole.murid).toList();
    final teacherCount =
        users.where((account) => account.role == UserRole.guru).length;
    final unassignedCount =
        students.where((account) => account.mentorAccountId == null).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Row(
            children: [
              BrandMark(compact: true),
              Spacer(),
            ],
          ),
          const SizedBox(height: 20),

          // Maroon Banner Panel Administrator
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.maroon, AppColors.maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANEL ADMINISTRATOR',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.85),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Halo, ${user.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola akun guru dan murid PKL dari satu tempat.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _AdminMetric(
                        label: 'MURID',
                        value: '${students.length}',
                        icon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminMetric(
                        label: 'GURU',
                        value: '$teacherCount',
                        icon: Icons.person_pin_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AdminMetric(
                        label: 'TOTAL AKUN',
                        value: '${users.length}',
                        icon: Icons.groups_2_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Kelola Akun Card (Matches Figma Home Screen)
          const SectionLabel('Kelola akun'),
          WhiteCard(
            padding: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.maroon,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftarkan guru atau murid',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Daftarkan NIP untuk guru dan NISN untuk murid.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onManageAccounts,
                  child: const Text('+ Buka pengelolaan akun'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mentorship Status Card
          const SectionLabel('Penetapan bimbingan'),
          WhiteCard(
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: unassignedCount > 0
                          ? AppColors.paleAmber
                          : AppColors.paleGreen,
                      child: Icon(
                        unassignedCount > 0
                            ? Icons.assignment_late_outlined
                            : Icons.assignment_turned_in_outlined,
                        color: unassignedCount > 0
                            ? AppColors.amber
                            : AppColors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pembimbing Murid',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            unassignedCount > 0
                                ? '$unassignedCount murid belum ditentukan pembimbingnya.'
                                : 'Seluruh murid telah memiliki pembimbing.',
                            style: TextStyle(
                              color: unassignedCount > 0
                                  ? AppColors.amber
                                  : AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InfoPill(
                      label: unassignedCount > 0 ? '$unassignedCount Perlu' : 'Lengkap',
                      color: unassignedCount > 0
                          ? AppColors.paleAmber
                          : AppColors.paleGreen,
                      textColor: unassignedCount > 0
                          ? AppColors.amber
                          : AppColors.green,
                    ),
                  ],
                ),
                if (onManageMentorship != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: onManageMentorship,
                    icon: const Icon(Icons.assignment_ind_outlined, size: 18),
                    label: const Text('Kelola Pembimbing Siswa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.maroon,
                      side: const BorderSide(color: AppColors.line),
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cream, size: 17),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 9,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
