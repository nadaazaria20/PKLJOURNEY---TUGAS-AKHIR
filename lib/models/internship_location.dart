class InternshipLocation {
  const InternshipLocation({
    required this.companyName,
    required this.address,
    this.latitude = -6.2146,
    this.longitude = 106.8189,
    this.radiusMeters = 50,
  });

  final String companyName;
  final String address;
  final double latitude;
  final double longitude;
  final int radiusMeters;

  factory InternshipLocation.fromJson(Map<String, dynamic> json) {
    return InternshipLocation(
      companyName: json['company_name'] as String? ?? 'PT Aksara Digital Nusantara',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.2146,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.8189,
      radiusMeters: (json['radius_meters'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson({required String teacherAccountId}) {
    return {
      'teacher_account_id': teacherAccountId,
      'company_name': companyName,
      'address': address,
    };
  }
}
