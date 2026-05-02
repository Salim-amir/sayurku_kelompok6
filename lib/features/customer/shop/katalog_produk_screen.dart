import 'keranjang_belanja_screen.dart';
import 'detail_produk_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import '../../../core/cart_manager.dart';
import '../../../../widgets/product_card.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../core/constants.dart';
import '../../../../models/product_model.dart';
import '../../../../services/product_service.dart';

class KatalogProdukScreen extends StatefulWidget {
  final String? kategoriAwal;
  final String? searchKeyword;
  const KatalogProdukScreen({super.key, this.kategoriAwal, this.searchKeyword});

  @override
  State<KatalogProdukScreen> createState() => _KatalogProdukScreenState();
}

class _KatalogProdukScreenState extends State<KatalogProdukScreen> {
late String _selectedKategori;

final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController(); // ← tambah ini
  String _searchKeyword = '';

  @override
void dispose() {
  _searchController.dispose();
  super.dispose();
}
@override
void initState() {
  super.initState();
  _selectedKategori = widget.kategoriAwal ?? 'sayur_hijau';
  if (widget.searchKeyword != null) {
    _searchKeyword = widget.searchKeyword!;
    _searchController.text = widget.searchKeyword!;
  }
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _selectedKategori = widget.kategoriAwal ?? 'sayur_hijau';
    });
  });
}

  final List<String> _kategoriList = [
    'sayur_hijau', 'buah', 'bumbu', 'umbi_umbian'
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
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text('Katalog Produk',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
          ),
        ),
        const SizedBox(width: 48), // biar judul tetap center
      ],
    ),
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
      autofocus: true, // ← tambah ini
      onChanged: (value) => setState(() => _searchKeyword = value),
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
// ── FILTER KATEGORI ─────────────────────────────────
Widget _buildKategoriFilter() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: _kategoriList.asMap().entries.map((entry) {
        final kategori = entry.value;
        final isSelected = kategori == _selectedKategori;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedKategori = kategori;
              });
            },
            borderRadius: BorderRadius.circular(20),
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
                _getLabelKategori(kategori),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

  // ── PRODUK GRID ─────────────────────────────────────
Widget _buildProdukGrid() {
  return StreamBuilder<List<ProductModel>>(
    stream: _searchKeyword.isEmpty
        ? _productService.getProdukByKategori(_selectedKategori)
        : _productService.cariProduk(_searchKeyword),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        );
      }
      if (snapshot.hasError) {
        return Center(
          child: Text('Gagal memuat produk', style: AppTextStyles.bodyMedium),
        );
      }
      final produkList = snapshot.data ?? [];
      if (produkList.isEmpty) {
        return Center(
          child: Text('Belum ada produk di kategori ini',
              style: AppTextStyles.bodyMedium),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final produk = produkList[index];
          return ProductCard(
            name: produk.nama,
            price: produk.harga,
            unit: produk.satuan,
            isAvailable: produk.tersedia,
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
  );
}

Widget _buildProductCard(Map<String, dynamic> produk) {
  return ProductCard(
    name: produk['nama'],
    price: produk['harga'],
    unit: produk['satuan'],
    isAvailable: true,
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProdukScreen(produk: produk),
      ),
    ),
    onAddToCart: () {},
  );
}
String _getLabelKategori(String kategori) {
  switch (kategori) {
    case 'sayur_hijau': return 'Sayur Hijau';
    case 'buah': return 'Buah';
    case 'bumbu': return 'Bumbu';
    case 'umbi_umbian': return 'Umbi-umbian';
    default: return kategori;
  }
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
  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}