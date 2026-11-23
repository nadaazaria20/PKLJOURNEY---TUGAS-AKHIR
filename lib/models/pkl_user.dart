enum UserRole { admin, guru, iduka, murid }

extension UserRoleDetails on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.guru => 'Guru Pembimbing',
        UserRole.iduka => 'Pembimbing IDUKA',
        UserRole.murid => 'Murid PKL',
      };

  String get accountIdLabel => switch (this) {
        UserRole.admin => 'Username',
        UserRole.guru => 'NIP',
        UserRole.iduka => 'ID Pembimbing IDUKA',
        UserRole.murid => 'NISN',
      };
}

class PklUser {
  const PklUser({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.accountId,
    this.mentorAccountId,
    this.idukaAccountId,
    this.companyName,
    this.address,
    this.phoneNumber,
    this.school = 'SMK Negeri 1 Jakarta',
  });

  final String username;
  final String password;
  final String name;
  final UserRole role;
  final String accountId;
  final String? mentorAccountId;
  final String? idukaAccountId;
  final String? companyName;
  final String? address;
  final String? phoneNumber;
  final String school;

  PklUser copyWith({
    String? username,
    String? password,
    String? name,
    String? mentorAccountId,
    String? idukaAccountId,
    String? companyName,
    String? address,
    String? phoneNumber,
    String? school,
    bool clearMentorAccountId = false,
    bool clearIdukaAccountId = false,
  }) {
    return PklUser(
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role,
      accountId: accountId,
      mentorAccountId: clearMentorAccountId
          ? null
          : mentorAccountId ?? this.mentorAccountId,
      idukaAccountId: clearIdukaAccountId
          ? null
          : idukaAccountId ?? this.idukaAccountId,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      school: school ?? this.school,
    );
  }

  factory PklUser.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'murid';
    final role = UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleStr.toLowerCase(),
      orElse: () => UserRole.murid,
    );

    return PklUser(
      username: json['username'] as String? ?? '',
      password: json['password_hash'] as String? ?? json['password'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: role,
      accountId: json['account_id'] as String? ?? '',
      mentorAccountId: json['mentor_account_id'] as String?,
      idukaAccountId: json['iduka_account_id'] as String?,
      companyName: json['company_name'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      school: json['school'] as String? ?? 'SMK Negeri 1 Jakarta',
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'username': username,
      'password_hash': password,
      'name': name,
      'role': role.name,
      'account_id': accountId,
      'mentor_account_id': mentorAccountId,
      'iduka_account_id': idukaAccountId,
      'company_name': companyName,
      'address': address,
      'phone_number': phoneNumber,
      'school': school,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'password_hash': password,
      'mentor_account_id': mentorAccountId,
      'iduka_account_id': idukaAccountId,
      'company_name': companyName,
      'address': address,
      'phone_number': phoneNumber,
      'school': school,
    };
  }
}

List<PklUser> createDemoUsers() => [
      const PklUser(
        username: 'admin',
        password: 'admin',
        name: 'Administrator PKLJOURNEY',
        role: UserRole.admin,
        accountId: 'admin',
        address: 'Jl. Budi Utomo No. 7, Jakarta Pusat',
        phoneNumber: '081234567890',
      ),
      const PklUser(
        username: 'guru',
        password: 'guru',
        name: 'Danang Dwi Gusti Fajar Yudha, S.Kom.',
        role: UserRole.guru,
        accountId: '19820109940201',
        address: 'Jl. Rawamangun Muka No. 12, Jakarta Timur',
        phoneNumber: '081398765432',
      ),
      const PklUser(
        username: 'septa',
        password: '123',
        name: 'Septa Subiyantono, S.Kom.',
        role: UserRole.guru,
        accountId: '1981010314010',
        address: 'Jl. Cempaka Putih Tengah No. 4, Jakarta Pusat',
        phoneNumber: '081512345678',
      ),
      const PklUser(
        username: 'iduka',
        password: 'iduka',
        name: 'Hendro Prasetyo, S.T.',
        role: UserRole.iduka,
        accountId: 'IDUKA-001',
        companyName: 'PT Aksara Digital Nusantara',
        address:
            'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
        phoneNumber: '082199887766',
      ),
      const PklUser(
        username: 'murid',
        password: 'murid',
        name: 'Frida Awan',
        role: UserRole.murid,
        accountId: '007812121134',
        mentorAccountId: '19820109940201',
        idukaAccountId: 'IDUKA-001',
        companyName: 'PT Aksara Digital Nusantara',
        address: 'Jl. Tebet Barat Dalam No. 15, Jakarta Selatan',
        phoneNumber: '085711223344',
      ),
      const PklUser(
        username: 'rakha',
        password: '123',
        name: 'Muhammad Rakha',
        role: UserRole.murid,
        accountId: '008127658190',
        address: 'Jl. Kebon Jeruk Raya No. 8, Jakarta Barat',
        phoneNumber: '087855667788',
      ),
    ];
