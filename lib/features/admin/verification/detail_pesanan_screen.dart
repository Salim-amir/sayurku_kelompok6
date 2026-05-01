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

  // KITA BUANG KATA 'late' AGAR ANTI ERROR MERAH!
  // Pakai tanda tanya (?) agar aman.
  Future<Map<String, dynamic>?>? _detailPesananFuture;

  // List pilihan status untuk dropdown
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
    // Kunci data Firebase di sini agar tidak me-reload saat tombol ditekan
    _detailPesananFuture = _orderService.getDetailPesanan(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
        // Memanggil variabel yang sudah dikunci di initState
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
          final alamat = orderData['alamatPengiriman'] ?? 'Alamat tidak tersedia';
          final statusSaatIni = orderData['status'] ?? 'Menunggu Konfirmasi';

          // Set nilai awal dropdown
          _selectedStatus ??= _statusOptions.contains(statusSaatIni)
              ? statusSaatIni
              : _statusOptions[0];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(AppConstants.colUsers)
                .doc(userId)
                .get(),
            builder: (context, userSnapshot) {
              String namaCustomer = 'Memuat...';
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                namaCustomer = userData['namaLengkap'] ?? 'Customer';
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── BUKTI TRANSFER ───
                    Text('BUKTI TRANSFER', style: AppTextStyles.labelUppercase),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://via.placeholder.com/400x200?text=Bukti+Transfer',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.zoom_in,
                              size: 16,
                              color: AppColors.white,
                            ),
                            label: const Text(
                              'Perbesar Gambar',
                              style: TextStyle(color: AppColors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.6,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── RINCIAN BELANJA ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
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
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusSaatIni.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ID Pesanan: #${widget.orderId.length > 8 ? widget.orderId.substring(0, 8) : widget.orderId}',
                            style: AppTextStyles.bodySmall,
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
                                    child: const Icon(
                                      Icons.eco,
                                      color: AppColors.primaryGreen,
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
                                    'Rp ${item['harga']}',
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
                    const SizedBox(height: 32),

                    // ─── ACTION BUTTONS ───
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputBorder.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _statusOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                'Update Status: $value',
                                style: AppTextStyles.inputText,
                              ),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);

                                // Panggil fungsi update status
                                final error = await _orderService
                                    .updateStatusPesanan(
                                      orderId: widget.orderId,
                                      statusBaru: _selectedStatus!,
                                    );

                                // Pengaman ekstra agar tidak crash
                                if (!mounted) return;

                                setState(() => _isLoading = false);

                                if (error == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Status berhasil diupdate!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  // Navigasi langsung dilempar balik!
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
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.verified,
                                color: AppColors.white,
                              ),
                        label: Text(
                          _isLoading ? 'Memproses...' : 'Simpan Perubahan',
                          style: AppTextStyles.buttonPrimary,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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