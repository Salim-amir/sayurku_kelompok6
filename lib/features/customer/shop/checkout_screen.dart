import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodePembayaran = 'COD';
  final int _ongkosKirim = 10000;

int get _subtotal => 44500; // dummy dulu
int get _totalPembayaran => _subtotal + _ongkosKirim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlamatPengiriman(),
                    const SizedBox(height: 16),
                    _buildRingkasanPesanan(),
                    const SizedBox(height: 16),
                    _buildMetodePembayaran(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Checkout',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── ALAMAT PENGIRIMAN ───────────────────────────────
  Widget _buildAlamatPengiriman() {
    return Container(
      width: double.infinity,
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
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text('Alamat Pengiriman', style: AppTextStyles.h3),
                ],
              ),
              Text('Ubah',
                  style: AppTextStyles.link.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Ibu Sari   (+62 812-3456-7890)',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Jl. Kebon Jeruk No. 12, RT 005/RW 003,\nKelurahan Palmerah, Kecamatan Jakarta Barat,\nDKI Jakarta, 11480',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── RINGKASAN PESANAN ───────────────────────────────
  Widget _buildRingkasanPesanan() {
final items = [
  {'nama': 'Bayam Hijau', 'harga': 12000, 'satuan': 'ikat', 'jumlah': 2},
  {'nama': 'Tomat Merah', 'harga': 8500, 'satuan': 'kg', 'jumlah': 1},
];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_basket_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text('Ringkasan Pesanan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          // List item
          ...items.map((item) => _buildItemPesanan(item)).toList(),
          const Divider(height: 24, color: AppColors.divider),
          // Subtotal & ongkir
          _buildBiayaRow('Subtotal', _subtotal),
          const SizedBox(height: 6),
          _buildBiayaRow('Ongkos Kirim', _ongkosKirim),
        ],
      ),
    );
  }

  Widget _buildItemPesanan(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.inputBackground,
              child: const Icon(Icons.image_rounded,
                  color: AppColors.textHint, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama'], style: AppTextStyles.h3),
                Text(
                  '${item['jumlah']} ${item['satuan']}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatHarga(item['harga'] * item['jumlah'])}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiayaRow(String label, int harga) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text('Rp ${_formatHarga(harga)}', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  // ── METODE PEMBAYARAN ───────────────────────────────
  Widget _buildMetodePembayaran() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text('Metode Pembayaran', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetodeItem(
            icon: Icons.handshake_rounded,
            label: 'COD (Bayar di Tempat)',
            value: 'COD',
          ),
          const SizedBox(height: 8),
          _buildMetodeItem(
            icon: Icons.account_balance_rounded,
            label: 'Transfer Bank',
            value: 'Transfer',
          ),
        ],
      ),
    );
  }

  Widget _buildMetodeItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _metodePembayaran == value;
    return GestureDetector(
      onTap: () => setState(() => _metodePembayaran = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.inputBorder,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL PEMBAYARAN',
                  style: AppTextStyles.labelUppercase.copyWith(fontSize: 10)),
              Text(
                'Rp ${_formatHarga(_totalPembayaran)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Nanti disambung ke order_service saat Firebase sudah siap
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Pesanan Dibuat!', style: AppTextStyles.h3),
                  content: Text(
                    'Pesanan kamu sedang diproses oleh admin.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: AppTextStyles.link),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Buat Pesanan', style: AppTextStyles.buttonPrimary),
          ),
        ],
      ),
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}