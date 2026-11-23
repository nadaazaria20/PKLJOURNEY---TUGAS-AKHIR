import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const PageHeading(
            title: 'Progres PKL',
            subtitle: 'Rekapitulasi kehadiran dan aktivitas praktikmu.',
          ),

          // Main Status Card
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Status Keaktifan PKL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: const LinearProgressIndicator(
                    value: 0.98,
                    minHeight: 10,
                    backgroundColor: Color(0xFF8A4242),
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tingkat kehadiran terverifikasi sangat baik (98%). Pertahankan keaktifanmu!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Pencapaian Aktivitas'),
          Row(
            children: const [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.fact_check_rounded,
                  value: '98%',
                  label: 'Kehadiran Valid',
                  color: AppColors.green,
                  background: AppColors.paleGreen,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.menu_book_rounded,
                  value: '14',
                  label: 'Jurnal Dibuat',
                  color: AppColors.maroon,
                  background: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: const [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.business_rounded,
                  value: 'Disetujui',
                  label: 'Verifikasi IDUKA',
                  color: AppColors.green,
                  background: AppColors.paleGreen,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.school_rounded,
                  value: '4.8 / 5.0',
                  label: 'Penilaian Guru',
                  color: AppColors.amber,
                  background: AppColors.paleAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          const SectionLabel('Informasi Pembimbingan'),
          const WhiteCard(
            padding: 16,
            child: Column(
              children: [
                _MentorshipInfoRow(
                  icon: Icons.business_rounded,
                  title: 'Pembimbing IDUKA (Industri)',
                  name: 'Hendro Prasetyo, S.T.',
                  company: 'PT Aksara Digital Nusantara',
                ),
                Divider(height: 20),
                _MentorshipInfoRow(
                  icon: Icons.school_rounded,
                  title: 'Guru Pembimbing Sekolah',
                  name: 'Danang Dwi Gusti Fajar Yudha, S.Kom.',
                  company: 'SMK Negeri 1 Jakarta',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorshipInfoRow extends StatelessWidget {
  const _MentorshipInfoRow({
    required this.icon,
    required this.title,
    required this.name,
    required this.company,
  });

  final IconData icon;
  final String title;
  final String name;
  final String company;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.cream,
          child: Icon(icon, color: AppColors.maroon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                company,
                style: const TextStyle(
                  color: AppColors.taupe,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: background,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
