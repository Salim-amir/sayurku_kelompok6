import 'keranjang_belanja_screen.dart';
import 'katalog_produk_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<Map<String, dynamic>> _kategori = const [
    {'label': 'Sayur Hijau', 'icon': Icons.eco_rounded, 'color': Color(0xFFE8F5E9)},
    {'label': 'Buah', 'icon': Icons.circle_rounded, 'color': Color(0xFFFFF3E0)},
    {'label': 'Bumbu', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFCE4EC)},
    {'label': 'Umbi-umbian', 'icon': Icons.grass_rounded, 'color': Color(0xFFF3E5F5)},
  ];

  final List<Map<String, dynamic>> _produk = const [
    {'nama': 'Bayam Hijau', 'satuan': '250g', 'harga': 12000, 'stok': 10},
    {'nama': 'Tomat Merah', 'satuan': '500g', 'harga': 15000, 'stok': 5},
    {'nama': 'Cabai Rawit', 'satuan': '100g', 'harga': 18000, 'stok': 8},
    {'nama': 'Wortel Lokal', 'satuan': '500g', 'harga': 10500, 'stok': 3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildCartFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildKategoriSection(),
              const SizedBox(height: 24),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildProdukSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accentGreen.withOpacity(0.15),
              child: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Text('Halo, Ibu Sari', style: AppTextStyles.h2),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 26),
          onPressed: () {},
        ),
      ],
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

  // ── KATEGORI ────────────────────────────────────────
Widget _buildKategoriSection() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Kategori', style: AppTextStyles.h3),
TextButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const KatalogProdukScreen()),
  ),
  child: Text('Lihat Semua',
      style: AppTextStyles.link.copyWith(fontSize: 13)),
),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _kategori.map((k) => _buildKategoriItem(k)).toList(),
      ),
    ],
  );
}

  Widget _buildKategoriItem(Map<String, dynamic> data) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: data['color'],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(data['icon'], color: AppColors.primaryGreen, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          data['label'],
          style: AppTextStyles.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── PROMO BANNER ────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.accentGreen,
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('PROMO HARI INI',
                style: AppTextStyles.labelUppercase
                    .copyWith(color: AppColors.white, fontSize: 10)),
          ),
          const SizedBox(height: 8),
          Text('Diskon 20%\nSayur Organik',
              style: AppTextStyles.h2.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }

  // ── PRODUK SECTION ──────────────────────────────────
  Widget _buildProdukSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Produk Segar', style: AppTextStyles.h3),
            const Icon(Icons.tune_rounded,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: _produk.length,
          itemBuilder: (context, index) =>
              _buildProductCard(_produk[index]),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> produk) {
    return Container(
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
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

  // ── HELPER ──────────────────────────────────────────
  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}