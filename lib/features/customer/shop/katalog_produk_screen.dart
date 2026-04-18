import 'keranjang_belanja_screen.dart';
import 'detail_produk_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';

class KatalogProdukScreen extends StatefulWidget {
  const KatalogProdukScreen({super.key});

  @override
  State<KatalogProdukScreen> createState() => _KatalogProdukScreenState();
}

class _KatalogProdukScreenState extends State<KatalogProdukScreen> {
  String _selectedKategori = 'Sayur Hijau';

  final List<String> _kategoriList = [
    'Sayur Hijau', 'Buah', 'Bumbu', 'Umbi-umbian'
  ];

  final List<Map<String, dynamic>> _produk = [
    {'nama': 'Bayam Hijau', 'kategori': 'SAYUR HIJAU', 'satuan': '250g', 'harga': 12000},
    {'nama': 'Tomat Merah', 'kategori': 'BUAH', 'satuan': '500g', 'harga': 15000},
    {'nama': 'Cabai Rawit', 'kategori': 'BUMBU', 'satuan': '100g', 'harga': 18000},
    {'nama': 'Wortel Lokal', 'kategori': 'UMBI-UMBIAN', 'satuan': '500g', 'harga': 10500},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildCartFAB(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 16),
            _buildKategoriFilter(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildProdukGrid(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Katalog Produk',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
          const Icon(Icons.search_rounded,
              color: AppColors.primaryGreen, size: 26),
        ],
      ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          const SizedBox(width: 10),
          Text('Cari sayur segar hari ini...', style: AppTextStyles.inputHint),
        ],
      ),
    );
  }

  // ── FILTER KATEGORI ─────────────────────────────────
  Widget _buildKategoriFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kategoriList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final kategori = _kategoriList[index];
          final isSelected = kategori == _selectedKategori;
          return GestureDetector(
            onTap: () => setState(() => _selectedKategori = kategori),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.inputBorder,
                ),
              ),
              child: Text(
                kategori,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── PRODUK GRID ─────────────────────────────────────
  Widget _buildProdukGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: _produk.length,
      itemBuilder: (context, index) => _buildProductCard(_produk[index]),
    );
  }

Widget _buildProductCard(Map<String, dynamic> produk) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProdukScreen(produk: produk),
      ),
    ),
    child: Container(
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
          // Foto produk
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: AppColors.inputBackground,
              child: const Icon(Icons.image_rounded,
                  color: AppColors.textHint, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk['kategori'],
                  style: AppTextStyles.labelUppercase.copyWith(
                    color: AppColors.primaryGreen,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(produk['nama'], style: AppTextStyles.h3),
                Text(produk['satuan'], style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatHarga(produk['harga'])}',
                      style: AppTextStyles.h3
                          .copyWith(color: AppColors.primaryGreen),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppColors.white, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── BOTTOM NAV ──────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded), label: 'Dompet'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: 'Profil'),
      ],
    );
  }

  // ── CART FAB ────────────────────────────────────────
 Widget _buildCartFAB() {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KeranjangBelanjaScreen()),
        ),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.shopping_basket_rounded,
            color: AppColors.white),
      ),
      Positioned(
        right: -2,
        top: -2,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('3',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    ],
  );
}
  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}