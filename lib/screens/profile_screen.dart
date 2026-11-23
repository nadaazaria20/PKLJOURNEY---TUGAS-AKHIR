import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    this.onUpdateUser,
  });

  final PklUser user;
  final VoidCallback onLogout;
  final ValueChanged<PklUser>? onUpdateUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late PklUser _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _currentUser = widget.user;
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.maroon),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.maroon),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) widget.onLogout();
  }

  void _openEditProfileDialog() {
    final nameController = TextEditingController(text: _currentUser.name);
    final phoneController =
        TextEditingController(text: _currentUser.phoneNumber ?? '');
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Icon(Icons.manage_accounts_rounded,
                            color: AppColors.maroon, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Ubah Profil & Kata Sandi',
                          style: Theme.of(sheetContext).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Perbarui data kontak atau ganti kata sandi akunmu.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'NAMA LENGKAP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.taupe,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nama lengkap Anda',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nama tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'NOMOR TELEPON / WHATSAPP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.taupe,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 081234567890',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'KATA SANDI BARU (OPSIONAL)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.taupe,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Biarkan kosong jika tidak ingin mengubah',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'KONFIRMASI KATA SANDI BARU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.taupe,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Ulangi kata sandi baru',
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                      ),
                      validator: (val) {
                        if (newPasswordController.text.isNotEmpty &&
                            val != newPasswordController.text) {
                          return 'Konfirmasi kata sandi tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.paleAmber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alamat dan penetapan IDUKA dikelola langsung oleh Administrator Sekolah.',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.taupe),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        final updated = _currentUser.copyWith(
                          name: nameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          password: newPasswordController.text.isNotEmpty
                              ? newPasswordController.text
                              : _currentUser.password,
                        );
                        setState(() => _currentUser = updated);
                        if (widget.onUpdateUser != null) {
                          widget.onUpdateUser!(updated);
                        }
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perubahan profil berhasil disimpan!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();

    final details = switch (user.role) {
      UserRole.admin => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username admin',
            value: user.accountId,
          ),
          const _ProfileDetail(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Akses',
            value: 'Kelola akun dan monitoring PKL',
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat Sekolah / Kantor',
            value: user.address ?? 'Jl. Budi Utomo No. 7, Jakarta Pusat',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon / Kontak',
            value: user.phoneNumber ?? '081234567890',
          ),
        ],
      UserRole.guru => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NIP Guru',
            value: user.accountId,
          ),
          _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: user.school,
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat (Dari Admin)',
            value: user.address ?? 'Belum diisi oleh admin',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon / Kontak',
            value: user.phoneNumber ?? 'Belum diisi',
          ),
          const _ProfileDetail(
            icon: Icons.work_outline_rounded,
            label: 'Peran',
            value: 'Guru Pembimbing Sekolah',
          ),
        ],
      UserRole.iduka => <Widget>[
          _ProfileDetail(
            icon: Icons.business_rounded,
            label: 'Nama Perusahaan / IDUKA',
            value: user.companyName ?? 'PT Aksara Digital Nusantara',
          ),
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'ID Pembimbing IDUKA',
            value: user.accountId,
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat Kantor / IDUKA',
            value: user.address ??
                'Gedung Menara Sudirman Lt. 12, Jl. Jend. Sudirman Kav. 28, Jakarta Pusat',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon / WA',
            value: user.phoneNumber ?? 'Belum diisi',
          ),
          const _ProfileDetail(
            icon: Icons.verified_user_outlined,
            label: 'Peran',
            value: 'Pembimbing Industri (IDUKA)',
          ),
        ],
      UserRole.murid => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NISN Siswa',
            value: user.accountId,
          ),
          _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: user.school,
          ),
          _ProfileDetail(
            icon: Icons.location_on_outlined,
            label: 'Alamat Rumah (Dari Admin)',
            value: user.address ?? 'Jl. Tebet Barat Dalam No. 15, Jakarta Selatan',
          ),
          _ProfileDetail(
            icon: Icons.phone_outlined,
            label: 'No. Telepon / Kontak',
            value: user.phoneNumber ?? '085711223344',
          ),
          _ProfileDetail(
            icon: Icons.business_outlined,
            label: 'Tempat PKL (IDUKA)',
            value: user.companyName ?? 'PT Aksara Digital Nusantara',
          ),
          const _ProfileDetail(
            icon: Icons.person_pin_outlined,
            label: 'Pembimbing IDUKA',
            value: 'Hendro Prasetyo, S.T.',
          ),
          const _ProfileDetail(
            icon: Icons.school_rounded,
            label: 'Guru Pembimbing Sekolah',
            value: 'Danang Dwi Gusti Fajar Yudha, S.Kom.',
          ),
        ],
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Profil ${user.role.label}',
            subtitle: 'Informasi akun dan pengaturan akses.',
            trailing: IconButton.filled(
              onPressed: _openEditProfileDialog,
              tooltip: 'Ubah Data & Sandi',
              icon: const Icon(Icons.edit_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.cream,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.maroon,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.role.label,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.cream,
                  size: 21,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Aksi Edit & Ubah Kata Sandi
          OutlinedButton.icon(
            onPressed: _openEditProfileDialog,
            icon: const Icon(Icons.key_rounded, size: 18),
            label: const Text('Ubah Kata Sandi & Kontak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(46),
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Informasi Akun Lengkap'),
          WhiteCard(
            padding: 0,
            child: Column(children: details),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar dari akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.line),
              minimumSize: const Size.fromHeight(49),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'PKLJOURNEY • Versi 1.0.0',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.maroon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
