import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';

class DetailPesananCustomerScreen extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const DetailPesananCustomerScreen({Key? key, required this.pesanan}) : super(key: key);

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _formatTanggal(DateTime date) {
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${bulan[date.month]} ${date.year}, $hour:$minute';
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    if (imageUrl.isEmpty) return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28);
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
      );
    }
    try {
      return Image.memory(
        base64Decode(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
      );
    } catch (_) {
      return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28);
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    
    final url = Uri.parse('https://wa.me/$cleanPhone');
    bool launched = false;
    try {
      launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launch WA: $e');
    }
    
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstal.')),
      );
    }
  }

  Color _colorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'dikirim':
        return AppColors.primaryGreen;
      case 'selesai':
        return AppColors.success;
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = pesanan['status'] ?? 'Tidak diketahui';
    final tanggal = pesanan['tanggalPesan']?.toDate();
    final items = List<Map<String, dynamic>>.from(pesanan['items'] ?? []);
    final totalHarga = (pesanan['totalHarga'] ?? 0).toDouble();
    final ongkosKirim = (pesanan['ongkosKirim'] ?? 0).toDouble();
    final subtotal = totalHarga - ongkosKirim;
    final alamat = pesanan['alamatPengiriman'] ?? 'Tidak ada alamat';
    final metode = pesanan['metodePembayaran'] ?? 'Tidak diketahui';
    final namaKurir = pesanan['namaKurir'];
    final noTelpKurir = pesanan['noTelpKurir'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. STATUS & TANGGAL ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status Pesanan', style: AppTextStyles.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _colorStatus(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _colorStatus(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Waktu Checkout', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      Text(
                        tanggal != null
                            ? _formatTanggal(tanggal)
                            : '-',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (pesanan['tanggalDikirim'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Waktu Dikirim', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Text(
                          _formatTanggal(pesanan['tanggalDikirim'].toDate()),
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  if (pesanan['tanggalSelesai'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Waktu Selesai', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        Text(
                          _formatTanggal(pesanan['tanggalSelesai'].toDate()),
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── 2. DAFTAR BARANG ───
            Text('Daftar Produk', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProductImage(
                                item['imageUrl']?.toString() ?? '',
                                60,
                                60,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama'] ?? 'Produk', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${item['jumlah'] ?? 1} x Rp ${_formatHarga((item['harga'] ?? 0).toInt())}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${_formatHarga(((item['harga'] ?? 0) * (item['jumlah'] ?? 1)).toInt())}',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ─── 3. INFORMASI PENGIRIMAN & KURIR ───
            Text('Informasi Pengiriman', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Tujuan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(alamat, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (namaKurir != null && namaKurir.toString().isNotEmpty) ...[
                    const Divider(height: 24, color: AppColors.divider),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delivery_dining, color: AppColors.primaryGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kurir Pengantar', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(namaKurir, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                              Text(noTelpKurir ?? '', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        if (noTelpKurir != null && noTelpKurir.toString().isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _launchWhatsApp(context, noTelpKurir.toString()),
                            icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                            label: const Text('Chat WA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366), // WA Color
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── 4. RINCIAN PEMBAYARAN ───
            Text('Rincian Pembayaran', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPaymentRow('Metode Pembayaran', metode, isBold: true),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildPaymentRow('Subtotal Produk', 'Rp ${_formatHarga(subtotal.toInt())}'),
                  const SizedBox(height: 8),
                  _buildPaymentRow('Ongkos Kirim', 'Rp ${_formatHarga(ongkosKirim.toInt())}'),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildPaymentRow('Total Belanja', 'Rp ${_formatHarga(totalHarga.toInt())}', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h3.copyWith(color: AppColors.primaryGreen)
              : AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
        ),
      ],
    );
  }

}
