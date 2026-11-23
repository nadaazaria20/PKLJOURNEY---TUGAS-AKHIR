class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.tag = 'Kegiatan',
    this.isReviewed = false,
    this.imageUrl,
    this.teacherNote,
  });

  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String tag;
  final bool isReviewed;
  final String? imageUrl;
  final String? teacherNote;

  JournalEntry copyWith({
    bool? isReviewed,
    String? teacherNote,
    String? imageUrl,
  }) =>
      JournalEntry(
        id: id,
        title: title,
        description: description,
        date: date,
        time: time,
        tag: tag,
        isReviewed: isReviewed ?? this.isReviewed,
        imageUrl: imageUrl ?? this.imageUrl,
        teacherNote: teacherNote ?? this.teacherNote,
      );

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Kegiatan',
      isReviewed: json['is_reviewed'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      teacherNote: json['teacher_note'] as String?,
    );
  }

  Map<String, dynamic> toJson({required String studentAccountId}) {
    return {
      if (id.isNotEmpty && !id.startsWith('demo-')) 'id': id,
      'student_account_id': studentAccountId,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'tag': tag,
      'is_reviewed': isReviewed,
      'image_url': imageUrl,
      'teacher_note': teacherNote,
    };
  }
}
