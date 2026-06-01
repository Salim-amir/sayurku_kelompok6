import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../services/wallet_service.dart';
import '../../../services/profile_service.dart';
import '../../../models/user_model.dart';
import 'riwayat_pesanan_screen.dart';
import 'dompet_digital_screen.dart';
import 'alamat_screen.dart';
import 'edit_profil_screen.dart';
import 'ganti_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final WalletService _walletService = WalletService();
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_rounded,
                  color: AppColors.textHint.withOpacity(0.4), size: 72),
              const SizedBox(height: 16),
              Text('Silakan login terlebih dahulu',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _profileService.getProfilStream(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen),
              );
            }

            final userData = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(userData),
                  const SizedBox(height: 20),
                  _buildSaldoCard(),
                  const SizedBox(height: 24),
                  _buildMenuSection(userData),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── PROFILE HEADER ─────────────────────────────────
  Widget _buildProfileHeader(UserModel? userData) {
    final nama = userData?.namaLengkap ?? 'Pengguna';
    final email = userData?.email ?? user?.email ?? '';
    final nomorHp = userData?.nomorHp ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accentGreen.withOpacity(0.15),
            backgroundImage: (userData?.fotoUrl ?? '').isNotEmpty
                ? MemoryImage(base64Decode(userData!.fotoUrl))
                : null,
            child: (userData?.fotoUrl ?? '').isEmpty
                ? Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primaryGreen,
                      fontSize: 32,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(nama, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(email,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          if (nomorHp.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(nomorHp,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint)),
          ],
          const SizedBox(height: 14),
          // Tombol Edit Profil
          OutlinedButton.icon(
            onPressed: () {
              final userMap = {
                'namaLengkap': userData?.namaLengkap ?? '',
                'nomorHp': userData?.nomorHp ?? '',
                'email': userData?.email ?? '',
                'fotoUrl': userData?.fotoUrl ?? '',
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        EditProfilScreen(userData: userMap)),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text('Edit Profil', style: AppTextStyles.bodyMedium),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── SALDO CARD ─────────────────────────────────────
  Widget _buildSaldoCard() {
    if (user == null) return const SizedBox();

    return StreamBuilder<double>(
      stream: _walletService.getSaldo(user!.uid),
      builder: (context, snapshot) {
        final saldo = snapshot.data ?? 0;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DompetDigitalScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D5C2E), Color(0xFF2D7A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Info saldo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Text('Saldo Dompet',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${_formatHarga(saldo.toInt())}',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.white,
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── MENU SECTION ───────────────────────────────────
  Widget _buildMenuSection(UserModel? userData) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.receipt_long_rounded,
            label: 'Riwayat Pesanan',
            subtitle: 'Lihat semua pesanan Anda',
            color: AppColors.info,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RiwayatPesananScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Dompet Digital',
            subtitle: 'Kelola saldo & riwayat',
            color: AppColors.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DompetDigitalScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on_rounded,
            label: 'Alamat Saya',
            subtitle: 'Kelola alamat pengiriman',
            color: AppColors.warning,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlamatScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock_rounded,
            label: 'Ganti Password',
            subtitle: 'Ubah kata sandi akun Anda',
            color: const Color(0xFF7B1FA2),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GantiPasswordScreen()),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.headset_mic_rounded,
            label: 'Customer Service',
            subtitle: 'Hubungi kami via WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () => _openWhatsApp(),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/6281217838842?text=Halo%20SayurKu%2C%20saya%20butuh%20bantuan');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka WhatsApp',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }

  // ── LOGOUT BUTTON ──────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text('Keluar dari Akun',
            style: AppTextStyles.bodyLarge
                .copyWith(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar', style: AppTextStyles.h3),
        content: Text('Apakah Anda yakin ingin keluar dari akun?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Keluar',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
