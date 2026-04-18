import 'keranjang_belanja_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';

class DetailProdukScreen extends StatefulWidget {
  final Map<String, dynamic> produk;
  const DetailProdukScreen({super.key, required this.produk});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  int _jumlah = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              _buildFotoProduk(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStokBadge(),
                    const SizedBox(height: 8),
                    _buildNamaDanHarga(),
                    const SizedBox(height: 20),
                    _buildInformasiProduk(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('SayurKu',
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen)),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded,
                color: AppColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ── FOTO PRODUK ─────────────────────────────────────
  Widget _buildFotoProduk() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.inputBackground,
              child: const Icon(Icons.image_rounded,
                  color: AppColors.textHint, size: 80),
            ),
          ),
          // Badge Fresh Harvest
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FRESH HARVEST',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.white,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STOK BADGE ──────────────────────────────────────
  Widget _buildStokBadge() {
    return Row(
      children: [
        const Icon(Icons.verified_rounded,
            color: AppColors.accentGreen, size: 18),
        const SizedBox(width: 6),
        Text(
          'Stok Harian: Tersedia',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── NAMA DAN HARGA ───────────────────────────────────
  Widget _buildNamaDanHarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.produk['nama'] ?? 'Nama Produk',
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Rp ${_formatHarga(widget.produk['harga'] ?? 0)}',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 6),
            Text(
              '/ ${widget.produk['satuan'] ?? 'ikat'}',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  // ── INFORMASI PRODUK ────────────────────────────────
  Widget _buildInformasiProduk() {
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
          Text('Informasi Produk', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            widget.produk['deskripsi'] ??
                'Produk segar organik dipetik langsung dari petani lokal di pagi hari. Kaya akan vitamin dan mineral. Cocok untuk berbagai masakan sehari-hari.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
        children: [
          // Tombol kurangi/tambah jumlah
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_jumlah > 1) setState(() => _jumlah--);
                  },
                  icon: const Icon(Icons.remove_rounded,
                      color: AppColors.textPrimary),
                ),
                Text('$_jumlah', style: AppTextStyles.h3),
                IconButton(
                  onPressed: () => setState(() => _jumlah++),
                  icon: const Icon(Icons.add_rounded,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Tambah ke Keranjang
          Expanded(
            child: ElevatedButton(
onPressed: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const KeranjangBelanjaScreen()),
),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Tambah ke Keranjang',
                  style: AppTextStyles.buttonPrimary),
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