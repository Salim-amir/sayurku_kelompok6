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

  Future<Map<String, dynamic>?>? _detailPesananFuture;

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
    _detailPesananFuture = _orderService.getDetailPesanan(widget.orderId);
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailPesananFuture,
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

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                namaCustomer = userData['namaLengkap'] ?? 'Customer';
                emailCustomer = userData['email'] ?? '-';
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
                            child: const Icon(
                              Icons.person,
                              color: AppColors.textHint,
                              size: 30,
                            ),
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
                                      child: (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty)
                                          ? Image.network(
                                              item['imageUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
                                            )
                                          : const Icon(Icons.eco_rounded, color: AppColors.primaryGreen),
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
                    // ─── FORM UPDATE STATUS PESANAN (Dipindah dari bottomNavigationBar agar scrollable) ───
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
                            'Update Status Pesanan',
                            style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.inputBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGreen),
                                items: _statusOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text('Status: $value', style: AppTextStyles.inputText),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    setState(() => _selectedStatus = newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                          if (_selectedStatus == 'Dikirim') ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _namaKurirController,
                              decoration: InputDecoration(
                                labelText: 'Nama Kurir',
                                hintText: 'Masukkan nama kurir',
                                labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGreen),
                                filled: true,
                                fillColor: AppColors.inputBackground,
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
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                ),
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
                                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_selectedStatus == 'Dikirim' &&
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
                                        statusBaru: _selectedStatus!,
                                        namaKurir: _selectedStatus == 'Dikirim' ? _namaKurirController.text.trim() : null,
                                        noTelpKurir: _selectedStatus == 'Dikirim' ? _noTelpKurirController.text.trim() : null,
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
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(error),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    },
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.verified, color: AppColors.white),
                              label: Text(
                                _isLoading ? 'Memproses...' : 'Simpan Perubahan',
                                style: AppTextStyles.buttonPrimary,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
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
}
