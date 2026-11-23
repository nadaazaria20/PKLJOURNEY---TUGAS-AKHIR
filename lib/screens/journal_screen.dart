import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    required this.entries,
    required this.onAddEntry,
  });

  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onAddEntry;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  Future<void> _openEntryForm() async {
    final entry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _JournalFormSheet(),
    );
    if (entry != null) widget.onAddEntry(entry);
  }

  List<JournalEntry> get _filteredEntries {
    return widget.entries.where((entry) {
      final matchesQuery = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' ||
          entry.tag.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Jurnal Kegiatan',
            subtitle: 'Dokumentasikan aktivitas dan keterampilan yang dipelajari.',
            trailing: IconButton.filled(
              onPressed: _openEntryForm,
              tooltip: 'Tambah Jurnal',
              icon: const Icon(Icons.add_a_photo_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paleAmber,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cream),
            ),
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined, color: AppColors.amber, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Wajib sertakan foto dokumentasi kegiatan untuk mempermudah penilaian guru pembimbing.',
                    style: TextStyle(
                      color: AppColors.taupe,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari catatan atau kegiatan PKL...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Semua',
                'Kegiatan',
                'Pembelajaran',
                'Orientasi',
                'Proyek'
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: AppColors.maroon,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.maroon : AppColors.line,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel(
            'Daftar Jurnal (${filtered.length})',
            action: '+ Tulis Baru',
            onAction: _openEntryForm,
          ),
          if (filtered.isEmpty)
            WhiteCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.maroon,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada jurnal yang cocok'
                          : 'Belum ada jurnal kegiatan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Coba ganti kata kunci pencarian atau kategori.'
                          : 'Catat pengalaman dan sertakan foto dokumentasimu hari ini.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _openEntryForm,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('Buat Jurnal Baru'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.maroon,
                        side: const BorderSide(color: AppColors.maroon),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _JournalCard(entry: entry),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openEntryForm,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Tambah Catatan & Foto Kegiatan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                entry.date,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InfoPill(
                label: entry.tag,
                color: AppColors.paper,
                textColor: AppColors.taupe,
              ),
              const SizedBox(width: 6),
              InfoPill(
                label: entry.isReviewed ? 'Disetujui' : 'Menunggu Review',
                color: entry.isReviewed
                    ? AppColors.paleGreen
                    : AppColors.paleAmber,
                textColor:
                    entry.isReviewed ? AppColors.green : AppColors.amber,
                icon: entry.isReviewed
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_top_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            entry.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.ink,
                  height: 1.5,
                ),
          ),
          if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            PklPhotoThumbnail(
              imageUrl: entry.imageUrl!,
              height: 160,
              caption: 'Dokumentasi: ${entry.title}',
            ),
          ],
          if (entry.teacherNote != null && entry.teacherNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.green.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rate_review_rounded,
                      color: AppColors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Guru Pembimbing:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '"${entry.teacherNote}"',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                'Ditambahkan pukul ${entry.time} WIB',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalFormSheet extends StatefulWidget {
  const _JournalFormSheet();

  @override
  State<_JournalFormSheet> createState() => _JournalFormSheetState();
}

class _JournalFormSheetState extends State<_JournalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _tag = 'Kegiatan';
  String? _selectedPhotoUrl = PklPhotoPresets.coding;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: currentDateLabel(),
      time:
          '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
      tag: _tag,
      imageUrl: _selectedPhotoUrl,
    );
    Navigator.of(context).pop(entry);
  }

  void _openPhotoPicker() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
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
              const Text(
                'Pilih Foto Dokumentasi PKL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih dari aktivitas standar PKL atau input URL foto kegiatanmu.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...PklPhotoPresets.presets.map((preset) {
                final url = preset['url']!;
                final label = preset['label']!;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.cream,
                        child: const Icon(Icons.photo, color: AppColors.maroon),
                      ),
                    ),
                  ),
                  title: Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Text('Kategori: ${preset['tag']}',
                      style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(sheetContext, url);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    ).then((chosenUrl) {
      if (chosenUrl != null) {
        setState(() => _selectedPhotoUrl = chosenUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded,
                        color: AppColors.maroon, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Tulis Jurnal Baru',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Catat tugas, proyek, atau materi baru yang kamu pelajari hari ini.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 18),
                const _FormLabel('JUDUL KEGIATAN'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Pengembangan modul API autentikasi',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Judul kegiatan wajib diisi'
                          : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('CERITA KEGIATAN & HASIL BELAJAR'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:
                        'Ceritakan alur pekerjaan, kendala yang dihadapi, dan solusi yang ditemukan...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 8
                          ? 'Ceritakan kegiatan minimal 8 karakter'
                          : null,
                ),
                const SizedBox(height: 15),
                const _FormLabel('KATEGORI KEGIATAN'),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: _tag,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Kegiatan', child: Text('Kegiatan Harian')),
                    DropdownMenuItem(
                      value: 'Pembelajaran',
                      child: Text('Pembelajaran / Riset'),
                    ),
                    DropdownMenuItem(value: 'Orientasi', child: Text('Orientasi / Meeting')),
                    DropdownMenuItem(value: 'Proyek', child: Text('Pengembangan Proyek')),
                  ],
                  onChanged: (value) =>
                      setState(() => _tag = value ?? 'Kegiatan'),
                ),
                const SizedBox(height: 16),
                const _FormLabel('FOTO DOKUMENTASI KEGIATAN'),
                const SizedBox(height: 7),
                if (_selectedPhotoUrl != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          _selectedPhotoUrl!,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            color: AppColors.cream,
                            child: const Center(
                              child: Icon(Icons.photo, color: AppColors.maroon),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _openPhotoPicker,
                              icon: const Icon(Icons.sync_rounded, size: 14),
                              label: const Text('Ganti Foto',
                                  style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.7),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton.filled(
                              onPressed: () =>
                                  setState(() => _selectedPhotoUrl = null),
                              icon: const Icon(Icons.close_rounded, size: 14),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.85),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(32, 32),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: _openPhotoPicker,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.maroon.withOpacity(0.4),
                            style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: AppColors.maroon, size: 26),
                          SizedBox(height: 6),
                          Text(
                            '+ Pilih / Ambil Foto Dokumentasi PKL',
                            style: TextStyle(
                              color: AppColors.maroon,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Simpan Jurnal & Foto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}
