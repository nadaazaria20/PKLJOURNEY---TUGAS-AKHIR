import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherReviewsScreen extends StatefulWidget {
  const TeacherReviewsScreen({
    super.key,
    required this.students,
    required this.journalEntries,
    required this.onMarkReviewed,
  });

  final List<PklUser> students;
  final Map<String, List<JournalEntry>> journalEntries;
  final void Function(
    String studentAccountId,
    String entryId, {
    String? teacherNote,
  }) onMarkReviewed;

  @override
  State<TeacherReviewsScreen> createState() => _TeacherReviewsScreenState();
}

class _TeacherReviewsScreenState extends State<TeacherReviewsScreen> {
  String _filter = 'Semua';

  List<_StudentJournal> get _reviews => [
        for (final student in widget.students)
          for (final entry in widget.journalEntries[student.accountId] ?? const [])
            _StudentJournal(student: student, entry: entry),
      ];

  void _openReviewDialog(BuildContext context, _StudentJournal item) {
    final noteController = TextEditingController(
      text: item.entry.teacherNote ?? 'Kegiatan PKL terverifikasi dengan baik.',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottom = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.rate_review_rounded,
                          color: AppColors.maroon, size: 22),
                      const SizedBox(width: 8),
                      Text('Tinjau & Beri Feedback',
                          style: Theme.of(sheetContext).textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Murid: ${item.student.name} • ${item.entry.title}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CATATAN / MASUKAN PEMBIMBING',
                    style: TextStyle(
                      color: AppColors.taupe,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Tuliskan apresiasi, masukan, atau arahan untuk murid...',
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      final note = noteController.text.trim();
                      widget.onMarkReviewed(
                        item.student.accountId,
                        item.entry.id,
                        teacherNote: note.isEmpty ? null : note,
                      );
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jurnal dan catatan berhasil diverifikasi.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Setujui & Simpan Catatan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    final pendingCount =
        reviews.where((review) => !review.entry.isReviewed).length;

    final filtered = reviews.where((r) {
      if (_filter == 'Menunggu') return !r.entry.isReviewed;
      if (_filter == 'Selesai') return r.entry.isReviewed;
      return true;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Tinjau Jurnal',
            subtitle: 'Evaluasi catatan kegiatan dan dokumentasi murid bimbingan.',
            trailing: InfoPill(
              label: '$pendingCount menunggu',
              color: pendingCount == 0
                  ? AppColors.paleGreen
                  : AppColors.paleAmber,
              textColor:
                  pendingCount == 0 ? AppColors.green : AppColors.amber,
              icon: Icons.rate_review_outlined,
            ),
          ),

          // Filter bar
          Row(
            children: ['Semua', 'Menunggu', 'Selesai'].map((f) {
              final isSelected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppColors.maroon,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.ink,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.maroon : AppColors.line,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty)
            const WhiteCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.checklist_rounded,
                        color: AppColors.green, size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Tidak ada jurnal pada kategori ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.ink, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: WhiteCard(
                  padding: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.cream,
                            child: Text(
                              review.student.name.isEmpty
                                  ? '?'
                                  : review.student.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.maroon,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review.student.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InfoPill(
                            label: review.entry.isReviewed
                                ? 'Disetujui'
                                : 'Perlu Tinjauan',
                            color: review.entry.isReviewed
                                ? AppColors.paleGreen
                                : AppColors.paleAmber,
                            textColor: review.entry.isReviewed
                                ? AppColors.green
                                : AppColors.amber,
                            icon: review.entry.isReviewed
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        review.entry.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        review.entry.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                      ),
                      if (review.entry.imageUrl != null) ...[
                        const SizedBox(height: 10),
                        PklPhotoThumbnail(
                          imageUrl: review.entry.imageUrl!,
                          height: 140,
                          caption:
                              'Dokumentasi: ${review.student.name} - ${review.entry.title}',
                        ),
                      ],
                      if (review.entry.teacherNote != null &&
                          review.entry.teacherNote!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.comment_rounded,
                                  color: AppColors.green, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Catatan Anda: "${review.entry.teacherNote}"',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${review.entry.date} • ${review.entry.time} WIB',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                _openReviewDialog(context, review),
                            icon: Icon(
                              review.entry.isReviewed
                                  ? Icons.edit_note_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 16,
                            ),
                            label: Text(
                              review.entry.isReviewed
                                  ? 'Ubah Catatan'
                                  : 'Beri Masukan / Setujui',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.maroon,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentJournal {
  const _StudentJournal({required this.student, required this.entry});

  final PklUser student;
  final JournalEntry entry;
}
