import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import '../../../../core/cart_manager.dart';
import 'checkout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KeranjangBelanjaScreen extends StatefulWidget {
  const KeranjangBelanjaScreen({super.key});

  @override
  State<KeranjangBelanjaScreen> createState() => _KeranjangBelanjaScreenState();
}

class _KeranjangBelanjaScreenState extends State<KeranjangBelanjaScreen> {
  List<Map<String, dynamic>> get _keranjang => CartManager.instance.items;
  int get _totalHarga => CartManager.instance.totalHarga;
  int get _totalProduk => CartManager.instance.totalProduk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PESANAN ANDA', style: AppTextStyles.labelUppercase),
                  const SizedBox(height: 4),
                  Text('Panen Segar\nHari Ini.',
                      style: AppTextStyles.h1.copyWith(fontSize: 28)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _keranjang.isEmpty
                  ? _buildKeranjangKosong()
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: _keranjang.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildItemKeranjang(index),
                  ),
            ),
            if (_keranjang.isNotEmpty) _buildBottomBar(context),
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
          Text('Keranjang',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── ITEM KERANJANG ───────────────────────────────────
Widget _buildItemKeranjang(int index) {
  final item = _keranjang[index];
  final imageUrl = item['imageUrl'] ?? '';

  return Container(
    padding: const EdgeInsets.all(12),
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
        // Foto produk
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFotoPlaceholder(),
                )
              : _buildFotoPlaceholder(),
        ),
        const SizedBox(width: 12),
        // Info produk
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nama'],
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                'Rp ${_formatHarga(item['harga'])} /${item['satuan']}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              // Tombol +/-
              Row(
                children: [
                  _buildQtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () => setState(() =>
                        CartManager.instance.updateJumlah(
                            index, item['jumlah'] - 1)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${item['jumlah']}',
                        style: AppTextStyles.h3.copyWith(
                            color: AppColors.primaryGreen)),
                  ),
                  _buildQtyButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() =>
                        CartManager.instance.updateJumlah(
                            index, item['jumlah'] + 1)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Harga total + tombol hapus
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () =>
                  setState(() => CartManager.instance.hapusProduk(index)),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
            ),
            Text(
              'Rp ${_formatHarga(item['harga'] * item['jumlah'])}',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFotoPlaceholder() {
  return Container(
    width: 80,
    height: 80,
    color: AppColors.inputBackground,
    child: const Icon(Icons.eco_rounded,
        color: AppColors.primaryGreen, size: 36),
  );
}
  Widget _buildQtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  // ── KERANJANG KOSONG ────────────────────────────────
  Widget _buildKeranjangKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Keranjang masih kosong', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('Yuk tambahkan sayuran segar!',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Estimasi',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                  Text(
                    'Rp ${_formatHarga(_totalHarga)}',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalProduk PRODUK',
                  style: AppTextStyles.labelUppercase.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const SizedBox(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lanjut ke Pembayaran',
                      style: AppTextStyles.buttonPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.white, size: 20),
                ],
              ),
            ),
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