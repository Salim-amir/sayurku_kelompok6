import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../models/address_model.dart';
import '../../../services/address_service.dart';

class AlamatScreen extends StatefulWidget {
  const AlamatScreen({super.key});

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  final AddressService _addressService = AddressService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormAlamat(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text('Tambah Alamat', style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildAlamatList()),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Alamat Saya',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── LIST ALAMAT ─────────────────────────────────────
  Widget _buildAlamatList() {
    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return StreamBuilder<List<AddressModel>>(
      stream: _addressService.getAlamatList(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final alamatList = snapshot.data ?? [];

        if (alamatList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: alamatList.length,
          itemBuilder: (context, index) {
            return _buildAlamatCard(alamatList[index]);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded,
              color: AppColors.textHint.withOpacity(0.4), size: 72),
          const SizedBox(height: 16),
          Text('Belum Ada Alamat',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Tambahkan alamat pengiriman Anda',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  // ── ALAMAT CARD ─────────────────────────────────────
  Widget _buildAlamatCard(AddressModel alamat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: alamat.isPrimary
            ? Border.all(color: AppColors.primaryGreen, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: label + badge utama
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alamat.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (alamat.isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Utama',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Menu more
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textHint, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) => _handleMenuAction(value, alamat),
                itemBuilder: (_) => [
                  if (!alamat.isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.warning, size: 18),
                          SizedBox(width: 8),
                          Text('Jadikan Utama'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded,
                            color: AppColors.info, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded,
                            color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nama penerima
          Text(
            '${alamat.namaPenerima}   (${alamat.nomorHp})',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          // Alamat lengkap
          Text(
            alamat.fullAddress,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── HANDLE MENU ACTION ─────────────────────────────
  void _handleMenuAction(String action, AddressModel alamat) async {
    switch (action) {
      case 'primary':
        final error = await _addressService.setAlamatUtama(
            userId: user!.uid, addressId: alamat.id);
        if (mounted && error != null) _showError(error);
        break;
      case 'edit':
        if (mounted) _showFormAlamat(context, alamat: alamat);
        break;
      case 'delete':
        if (mounted) _confirmDelete(alamat);
        break;
    }
  }

  void _confirmDelete(AddressModel alamat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Alamat', style: AppTextStyles.h3),
        content: Text('Hapus alamat "${alamat.label}"?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final error = await _addressService.hapusAlamat(
                  userId: user!.uid, addressId: alamat.id);
              if (error != null && mounted) _showError(error);
            },
            child: Text('Hapus',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── FORM TAMBAH / EDIT ALAMAT (Bottom Sheet) ───────
  void _showFormAlamat(BuildContext context, {AddressModel? alamat}) {
    final isEdit = alamat != null;
    final labelCtrl = TextEditingController(text: alamat?.label ?? '');
    final namaCtrl = TextEditingController(text: alamat?.namaPenerima ?? '');
    final hpCtrl = TextEditingController(text: alamat?.nomorHp ?? '');
    final alamatCtrl =
        TextEditingController(text: alamat?.alamatLengkap ?? '');
    final kecCtrl = TextEditingController(text: alamat?.kecamatan ?? '');
    final kotaCtrl = TextEditingController(text: alamat?.kota ?? '');
    final posCtrl = TextEditingController(text: alamat?.kodePos ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? 'Edit Alamat' : 'Tambah Alamat',
                      style: AppTextStyles.h2),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    _buildFormField('Label Alamat', 'Contoh: Rumah, Kantor',
                        labelCtrl, Icons.label_rounded),
                    _buildFormField('Nama Penerima', 'Nama lengkap penerima',
                        namaCtrl, Icons.person_rounded),
                    _buildFormField('Nomor HP', '08xx xxxx xxxx', hpCtrl,
                        Icons.phone_rounded,
                        keyboardType: TextInputType.phone),
                    _buildFormField('Alamat Lengkap',
                        'Jl, RT/RW, No. Rumah', alamatCtrl,
                        Icons.location_on_rounded,
                        maxLines: 2),
                    _buildFormField(
                        'Kecamatan', 'Kecamatan', kecCtrl, Icons.map_rounded),
                    _buildFormField(
                        'Kota', 'Kota / Kabupaten', kotaCtrl,
                        Icons.location_city_rounded),
                    _buildFormField('Kode Pos', '12345', posCtrl,
                        Icons.markunread_mailbox_rounded,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (labelCtrl.text.isEmpty ||
                              namaCtrl.text.isEmpty ||
                              hpCtrl.text.isEmpty ||
                              alamatCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lengkapi field yang wajib diisi',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.white),
                                ),
                                backgroundColor: AppColors.warning,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }

                          final newAlamat = AddressModel(
                            id: alamat?.id ?? '',
                            label: labelCtrl.text.trim(),
                            namaPenerima: namaCtrl.text.trim(),
                            nomorHp: hpCtrl.text.trim(),
                            alamatLengkap: alamatCtrl.text.trim(),
                            kecamatan: kecCtrl.text.trim(),
                            kota: kotaCtrl.text.trim(),
                            kodePos: posCtrl.text.trim(),
                            isPrimary: alamat?.isPrimary ?? false,
                          );

                          String? error;
                          if (isEdit) {
                            error = await _addressService.updateAlamat(
                              userId: user!.uid,
                              addressId: alamat!.id,
                              alamat: newAlamat,
                            );
                          } else {
                            error = await _addressService.tambahAlamat(
                              userId: user!.uid,
                              alamat: newAlamat,
                            );
                          }

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (error != null) {
                              _showError(error);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Alamat',
                            style: AppTextStyles.buttonPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint,
      TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelUppercase),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.inputHint,
              prefixIcon:
                  Icon(icon, color: AppColors.textHint, size: 20),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primaryGreen, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
