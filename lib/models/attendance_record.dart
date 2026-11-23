const _indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const _indonesianWeekdays = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.isApprovedByIduka = false,
    this.idukaApproverName,
    this.idukaApprovalTime,
    this.notes,
  });

  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final bool isApprovedByIduka;
  final String? idukaApproverName;
  final String? idukaApprovalTime;
  final String? notes;

  bool get isApproved => isApprovedByIduka;

  String get approvalStatusLabel {
    if (isApprovedByIduka) return 'Disetujui Pembimbing IDUKA';
    return 'Menunggu Konfirmasi IDUKA';
  }

  AttendanceRecord copyWith({
    String? checkInTime,
    String? checkOutTime,
    String? checkInPhoto,
    String? checkOutPhoto,
    bool? isApprovedByIduka,
    String? idukaApproverName,
    String? idukaApprovalTime,
    String? notes,
    bool clearIdukaApprover = false,
  }) {
    return AttendanceRecord(
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInPhoto: checkInPhoto ?? this.checkInPhoto,
      checkOutPhoto: checkOutPhoto ?? this.checkOutPhoto,
      isApprovedByIduka: isApprovedByIduka ?? this.isApprovedByIduka,
      idukaApproverName: clearIdukaApprover
          ? null
          : idukaApproverName ?? this.idukaApproverName,
      idukaApprovalTime: clearIdukaApprover
          ? null
          : idukaApprovalTime ?? this.idukaApprovalTime,
      notes: notes ?? this.notes,
    );
  }

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;

  String get shortDate =>
      '${date.day.toString().padLeft(2, '0')} ${_indonesianMonths[date.month - 1]} ${date.year}';

  String get shortWeekday => _indonesianWeekdays[date.weekday - 1];

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final dateVal = json['date'];
    if (dateVal is DateTime) {
      parsedDate = dateVal;
    } else if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return AttendanceRecord(
      date: parsedDate,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      checkInPhoto: json['check_in_photo'] as String?,
      checkOutPhoto: json['check_out_photo'] as String?,
      isApprovedByIduka: json['is_approved_by_iduka'] as bool? ?? false,
      idukaApproverName: json['iduka_approver_name'] as String?,
      idukaApprovalTime: json['iduka_approval_time'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson({required String studentAccountId}) {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return {
      'student_account_id': studentAccountId,
      'date': dateStr,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'is_approved_by_iduka': isApprovedByIduka,
      'iduka_approver_name': idukaApproverName,
      'iduka_approval_time': idukaApprovalTime,
      'notes': notes,
    };
  }
}
