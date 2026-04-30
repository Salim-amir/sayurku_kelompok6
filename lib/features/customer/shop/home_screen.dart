import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../widgets/product_card.dart';
import 'katalog_produk_screen.dart';
import 'detail_produk_screen.dart';
import 'keranjang_belanja_screen.dart';
import '../profile/riwayat_pesanan_screen.dart';
import '../profile/dompet_digital_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/notifikasi_screen.dart';
import '../../../core/cart_manager.dart';
import '../../../services/promo_service.dart';
import '../../../models/promo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final PromoService _promoService = PromoService();
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _kategori = const [
    {'label': 'Sayur Hijau', 'kategoriKey': 'sayur_hijau', 'icon': Icons.eco_rounded, 'color': Color(0xFFE8F5E9)},
    {'label': 'Buah', 'kategoriKey': 'buah', 'icon': Icons.circle_rounded, 'color': Color(0xFFFFF3E0)},
    {'label': 'Bumbu', 'kategoriKey': 'bumbu', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFCE4EC)},
    {'label': 'Umbi-umbian', 'kategoriKey': 'umbi_umbian', 'icon': Icons.grass_rounded, 'color': Color(0xFFF3E5F5)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 ? _buildCartFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }

  // ── BODY (switch berdasarkan tab) ───────────────────
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const RiwayatPesananScreen(showBackButton: false);
      case 2:
        return const DompetDigitalScreen(showBackButton: false);
      case 3:
        return const NotifikasiScreen(showBackButton: false);
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  // ── HOME BODY ──────────────────────────────────────
  Widget _buildHomeBody() {
    return SafeArea(
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
    );
  }

  // ── HEADER ──────────────────────────────────────────
 Widget _buildHeader() {
  final namaUser = user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna';
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () => setState(() => _currentIndex = 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accentGreen.withOpacity(0.15),
              child: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Text('Halo, $namaUser', style: AppTextStyles.h2),
          ],
        ),
      ),
    ],
  );
}
  // ── SEARCH BAR ──────────────────────────────────────
 Widget _buildSearchBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchKeyword = value);
        if (value.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KatalogProdukScreen(
                searchKeyword: value,
              ),
            ),
          );
        }
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Cari sayur segar hari ini...',
        hintStyle: AppTextStyles.inputHint,
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textHint, size: 20),
        suffixIcon: _searchKeyword.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textHint, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchKeyword = '');
                },
              )
            : null,
      ),
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
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KatalogProdukScreen(
          kategoriAwal: data['kategoriKey'],
        ),
      ),
    ),
    child: Column(
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
    ),
  );
}

  // ── PROMO BANNER ────────────────────────────────────
Widget _buildPromoBanner() {
  return StreamBuilder<List<PromoModel>>(
    stream: _promoService.getPromos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      final promos = snapshot.data ?? [];
      if (promos.isEmpty) {
        return _buildDefaultBanner();
      }

      // Tampilkan promo pertama
      final promo = promos.first;
      return Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.accentGreen,
          image: promo.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(promo.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                      Colors.black26, BlendMode.darken),
                )
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('PROMO HARI INI',
                  style: AppTextStyles.labelUppercase
                      .copyWith(color: AppColors.white, fontSize: 10)),
            ),
            const SizedBox(height: 8),
            Text(promo.title,
                style: AppTextStyles.h2.copyWith(color: AppColors.white)),
            if (promo.subtitle.isNotEmpty)
              Text(promo.subtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white)),
          ],
        ),
      );
    },
  );
}

Widget _buildDefaultBanner() {
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
  // ── PRODUK SECTION (FIREBASE) ───────────────────────
  Widget _buildProdukSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Produk Segar', style: AppTextStyles.h3),
          ],
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<ProductModel>>(
          stream: _productService.getSemuaProduk(),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }
            // Error
            if (snapshot.hasError) {
              return Center(
                child: Text('Gagal memuat produk',
                    style: AppTextStyles.bodyMedium),
              );
            }
            // Kosong
            final produkList = snapshot.data ?? [];
            if (produkList.isEmpty) {
              return Center(
                child: Text('Belum ada produk tersedia',
                    style: AppTextStyles.bodyMedium),
              );
            }
            // Tampilkan produk
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: produkList.length,
              itemBuilder: (context, index) {
                final produk = produkList[index];
                return ProductCard(
                  name: produk.nama,
                  price: produk.harga.toInt(),
                  unit: produk.satuan,
                  isAvailable: produk.tersedia,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProdukScreen(
                        produk: {
                          'id': produk.id,
                          'nama': produk.nama,
                          'harga': produk.harga.toInt(),
                          'satuan': produk.satuan,
                          'imageUrl': produk.imageUrl,
                          'tersedia': produk.tersedia,
                        },
                      ),
                    ),
                  ),
                  onAddToCart: () {
  CartManager.instance.tambahProduk({
    'nama': produk.nama,
    'harga': produk.harga.toInt(),
    'satuan': produk.satuan,
    'imageUrl': produk.imageUrl,
  }, 1);
  setState(() {});
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${produk.nama} ditambahkan ke keranjang!'),
      backgroundColor: AppColors.primaryGreen,
      duration: const Duration(seconds: 2),
    ),
  );
},
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ── BOTTOM NAV ──────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded), label: 'Dompet'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const KeranjangBelanjaScreen()),
          );
          setState(() {}); // refresh badge setelah balik dari keranjang
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.shopping_basket_rounded,
            color: AppColors.white),
      ),
      if (CartManager.instance.totalProduk > 0)
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
            child: Center(
              child: Text(
                '${CartManager.instance.totalProduk}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
    ],
  );
}
}