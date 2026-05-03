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
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
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
String _namaUser = 'Pengguna';

@override
void initState() {
  super.initState();
  _loadNamaUser();
}

void _loadNamaUser() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (doc.exists) {
    setState(() {
      _namaUser = doc.data()?['namaLengkap'] ?? 
                  doc.data()?['username'] ?? 
                  doc.data()?['nama'] ?? 
                  'Pengguna';
    });
  }
}

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
            _buildProdukTerlaris(),
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () => setState(() => _currentIndex = 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
              child: Text(
                _namaUser.isNotEmpty ? _namaUser[0].toUpperCase() : 'P',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('Halo, $_namaUser', style: AppTextStyles.h2),
          ],
        ),
      ),
    ],
  );
}
  // ── SEARCH BAR ──────────────────────────────────────
 Widget _buildSearchBar() {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KatalogProdukScreen(),
      ),
    ),
    child: Container(
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

Widget _buildProdukTerlaris() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 8),
              Text('Produk Terlaris', style: AppTextStyles.h3),
            ],
          ),
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
      const SizedBox(height: 12),
      StreamBuilder<List<ProductModel>>(
        stream: _productService.getSemuaProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          final produkList = snapshot.data ?? [];
          if (produkList.isEmpty) return const SizedBox();

          final terlaris = produkList.take(5).toList();

          return SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: terlaris.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final produk = terlaris[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProdukScreen(
                        produk: {
                          'id': produk.id,
                          'nama': produk.nama,
                          'harga': produk.harga,
                          'satuan': produk.satuan,
                          'imageUrl': produk.imageUrl,
                          'tersedia': produk.tersedia,
                        },
                      ),
                    ),
                  ),
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto dengan badge
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: produk.imageUrl.isNotEmpty
                                  ? Image.network(
                                      produk.imageUrl,
                                      width: 150,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 150,
                                        height: 120,
                                        color: AppColors.inputBackground,
                                        child: const Icon(Icons.eco_rounded,
                                            color: AppColors.primaryGreen, size: 40),
                                      ),
                                    )
                                  : Container(
                                      width: 150,
                                      height: 120,
                                      color: AppColors.inputBackground,
                                      child: const Icon(Icons.eco_rounded,
                                          color: AppColors.primaryGreen, size: 40),
                                    ),
                            ),
                            // Badge ranking
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? Colors.amber
                                      : index == 1
                                          ? Colors.grey[400]
                                          : index == 2
                                              ? Colors.brown[300]
                                              : AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      index < 3
                                          ? Icons.emoji_events_rounded
                                          : Icons.local_fire_department_rounded,
                                      color: AppColors.white,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '#${index + 1}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Info produk
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produk.nama,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${_formatHarga(produk.harga)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      CartManager.instance.tambahProduk({
                                        'nama': produk.nama,
                                        'harga': produk.harga,
                                        'satuan': produk.satuan,
                                        'imageUrl': produk.imageUrl,
                                      }, 1);
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${produk.nama} ditambahkan!'),
                                          backgroundColor:
                                              AppColors.primaryGreen,
                                          duration:
                                              const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add_rounded,
                                          color: AppColors.white, size: 18),
                                    ),
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
              },
            ),
          );
        },
      ),
    ],
  );
}

String _formatHarga(int harga) {
  return harga.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
                  imagePath: produk.imageUrl,
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