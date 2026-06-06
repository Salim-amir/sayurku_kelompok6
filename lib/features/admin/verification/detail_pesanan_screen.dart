import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import '/../services/order_service.dart';

class DetailPesananScreen extends StatefulWidget {
  final String orderId;

  const DetailPesananScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<DetailPesananScreen> createState() => _DetailPesananScreenState();
}

class _DetailPesananScreenState extends State<DetailPesananScreen> {
  final OrderService _orderService = OrderService();
  String? _selectedStatus;
  bool _isLoading = false;
  final TextEditingController _namaKurirController = TextEditingController();
  final TextEditingController _noTelpKurirController = TextEditingController();
  bool _isInitialized = false;


  final List<String> _statusOptions = [
    'Menunggu Konfirmasi',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _namaKurirController.dispose();
    _noTelpKurirController.dispose();
    super.dispose();
  }

  // ─── HELPER WARNA STATUS ───
  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return const Color(0xFFC41E3A); // Merah
      case 'diproses':
      case 'dikirim':
        return const Color(0xFFE67E22); // Orange
      case 'selesai':
        return AppColors.success; // Hijau
      case 'dibatalkan':
        return AppColors.error; // Merah
      default:
        return AppColors.textSecondary;
    }
  }

  Color _bgStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return const Color(0xFFC41E3A).withOpacity(0.12);
      case 'diproses':
      case 'dikirim':
        return const Color(0xFFE67E22).withOpacity(0.12);
      case 'selesai':
        return AppColors.success.withOpacity(0.12);
      case 'dibatalkan':
        return AppColors.error.withOpacity(0.12);
      default:
        return AppColors.inputBackground;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Pesanan',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _orderService.streamDetailPesanan(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data pesanan tidak ditemukan.'));
          }

          final orderData = snapshot.data!;
          final userId = orderData['userId'] ?? '';
          final items = List<Map<String, dynamic>>.from(
            orderData['items'] ?? [],
          );
          final totalHarga = (orderData['totalHarga'] ?? 0).toInt();
          final alamat =
              orderData['alamatPengiriman'] ?? 'Alamat tidak tersedia';
          final imageUrl = orderData['buktiTransfer'] as String?;

          // Pelacak Status Pintar (Abaikan Huruf Besar/Kecil)
          final rawStatus = (orderData['status'] ?? 'Menunggu Konfirmasi')
              .toString();
          final statusSaatIni = _statusOptions.firstWhere(
            (option) => option.toLowerCase() == rawStatus.toLowerCase(),
            orElse: () => _statusOptions[0],
          );
          
          if (!_isInitialized) {
            _selectedStatus = statusSaatIni;
            _namaKurirController.text = orderData['namaKurir'] ?? '';
            _noTelpKurirController.text = orderData['noTelpKurir'] ?? '';
            _isInitialized = true;
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(AppConstants.colUsers)
                .doc(userId)
                .get(),
            builder: (context, userSnapshot) {
              String namaCustomer = 'Memuat...';
              String emailCustomer = '-';
              String fotoCustomer = '';

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                namaCustomer = userData['namaLengkap'] ?? 'Customer';
                emailCustomer = userData['email'] ?? '-';
                fotoCustomer = userData['fotoUrl'] ?? userData['photoUrl'] ?? '';
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── KARTU USER INFO ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.inputBackground,
                            backgroundImage: fotoCustomer.isNotEmpty
                                ? (fotoCustomer.startsWith('http')
                                    ? NetworkImage(fotoCustomer) as ImageProvider
                                    : MemoryImage(base64Decode(fotoCustomer)))
                                : null,
                            child: fotoCustomer.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    color: AppColors.textHint,
                                    size: 30,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaCustomer, style: AppTextStyles.h3),
                                const SizedBox(height: 2),
                                Text(
                                  '#${widget.orderId.length > 8 ? widget.orderId.substring(0, 8) : widget.orderId}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  emailCustomer,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── RINCIAN BELANJA ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rincian\nBelanja', style: AppTextStyles.h2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _bgStatus(statusSaatIni),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusSaatIni.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: _colorStatus(statusSaatIni),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // List Item Pesanan
                          ...items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildProductImage(
                                          item['imageUrl']?.toString() ?? '',
                                          50,
                                          50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['nama'] ?? 'Produk',
                                          style: AppTextStyles.h3,
                                        ),
                                        Text(
                                          'x${item['jumlah']} ${item['satuan'] ?? 'unit'}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp ${item['harga'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                    style: AppTextStyles.h3.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const Divider(
                            height: 24,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pembayaran',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── ALAMAT PENGIRIMAN ───
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alamat Pengiriman',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaCustomer, style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          Text(
                            alamat,
                            style: AppTextStyles.bodySmall.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ─── AKSI PESANAN ───
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aksi Pesanan',
                            style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButtons(statusSaatIni, orderData),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<void> _updateStatus(String statusBaru) async {
    if (statusBaru == 'Dikirim' &&
        (_namaKurirController.text.trim().isEmpty ||
         _noTelpKurirController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan No. Telepon kurir wajib diisi!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final error = await _orderService.updateStatusPesanan(
      orderId: widget.orderId,
      statusBaru: statusBaru,
      namaKurir: statusBaru == 'Dikirim' ? _namaKurirController.text.trim() : null,
      noTelpKurir: statusBaru == 'Dikirim' ? _noTelpKurirController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diupdate!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
              )
            : Icon(icon, color: AppColors.white),
        label: Text(
          _isLoading ? 'Memproses...' : label,
          style: AppTextStyles.buttonPrimary,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: AppColors.error),
        label: Text(
          label,
          style: AppTextStyles.buttonPrimary.copyWith(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Ya, Lanjutkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditKurirDialog(String currentNama, String currentTelp) {
    final TextEditingController namaController = TextEditingController(text: currentNama);
    final TextEditingController telpController = TextEditingController(text: currentTelp);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Data Kurir', style: AppTextStyles.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Kurir',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: telpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'No. Telp Kurir',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (namaController.text.trim().isEmpty || telpController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data kurir harus diisi!')));
                  return;
                }
                Navigator.pop(context);

                setState(() => _isLoading = true);
                final error = await _orderService.updateKurirPesanan(
                  orderId: widget.orderId,
                  namaKurir: namaController.text.trim(),
                  noTelpKurir: telpController.text.trim(),
                );

                if (!mounted) return;
                setState(() => _isLoading = false);

                if (error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data kurir berhasil diupdate!'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: AppColors.error),
                  );
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(String statusSaatIni, Map<String, dynamic> orderData) {
    if (statusSaatIni == 'Menunggu Konfirmasi') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrimaryButton(
            label: 'Terima & Proses Pesanan',
            icon: Icons.check_circle_outline,
            onPressed: () => _showConfirmationDialog(
              title: 'Terima Pesanan?',
              message: 'Apakah Anda yakin ingin menerima dan memproses pesanan ini?',
              onConfirm: () => _updateStatus('Diproses'),
            ),
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'Batalkan Pesanan',
            icon: Icons.cancel_outlined,
            onPressed: () => _showConfirmationDialog(
              title: 'Batalkan Pesanan?',
              message: 'Apakah Anda yakin ingin membatalkan pesanan ini? Aksi ini tidak dapat dibatalkan.',
              isDestructive: true,
              onConfirm: () => _updateStatus('Dibatalkan'),
            ),
          ),
        ],
      );
    } else if (statusSaatIni == 'Diproses') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Kurir', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _namaKurirController,
            decoration: InputDecoration(
              labelText: 'Nama Kurir',
              hintText: 'Masukkan nama kurir',
              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGreen),
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noTelpKurirController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'No. Telepon Kurir',
              hintText: '08123456789',
              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGreen),
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Kirim Pesanan',
            icon: Icons.local_shipping_outlined,
            onPressed: () {
              if (_namaKurirController.text.trim().isEmpty || _noTelpKurirController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama dan No. Telepon kurir wajib diisi!'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              _showConfirmationDialog(
                title: 'Kirim Pesanan?',
                message: 'Pastikan pesanan sudah diserahkan ke kurir dan data kurir sudah benar.',
                onConfirm: () => _updateStatus('Dikirim'),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'Batalkan Pesanan',
            icon: Icons.cancel_outlined,
            onPressed: () => _showConfirmationDialog(
              title: 'Batalkan Pesanan?',
              message: 'Apakah Anda yakin ingin membatalkan pesanan ini? Aksi ini tidak dapat dibatalkan.',
              isDestructive: true,
              onConfirm: () => _updateStatus('Dibatalkan'),
            ),
          ),
        ],
      );
    } else if (statusSaatIni == 'Dikirim') {
      final namaKurir = orderData['namaKurir'] ?? '-';
      final telpKurir = orderData['noTelpKurir'] ?? '-';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.delivery_dining_rounded, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('Informasi Kurir', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showEditKurirDialog(namaKurir, telpKurir),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit_rounded, color: AppColors.primaryGreen, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Nama: $namaKurir', style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text('No. Telp: $telpKurir', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Selesaikan Pesanan',
            icon: Icons.task_alt_rounded,
            onPressed: () => _showConfirmationDialog(
              title: 'Selesaikan Pesanan?',
              message: 'Pastikan pesanan telah diterima dengan baik oleh pelanggan sebelum menyelesaikan pesanan.',
              onConfirm: () => _updateStatus('Selesai'),
            ),
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'Batalkan Pesanan',
            icon: Icons.cancel_outlined,
            onPressed: () => _showConfirmationDialog(
              title: 'Batalkan Pesanan?',
              message: 'Apakah Anda yakin ingin membatalkan pesanan ini? Pesanan yang sudah dikirim akan dibatalkan.',
              isDestructive: true,
              onConfirm: () => _updateStatus('Dibatalkan'),
            ),
          ),
        ],
      );
    } else {
      // Selesai or Dibatalkan
      return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _bgStatus(statusSaatIni),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Pesanan ini telah $statusSaatIni',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _colorStatus(statusSaatIni),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    if (imageUrl.isEmpty) return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen);
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
      );
    }
    try {
      return Image.memory(
        base64Decode(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
      );
    } catch (_) {
      return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen);
    }
  }
}
