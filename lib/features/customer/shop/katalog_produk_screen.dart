import 'dart:convert'; // ✅ TAMBAHAN untuk base64Decode
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
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  Stream<List<ProductModel>>? _stream;
  String _lastKategori = '';
  String _lastKeyword = '';

  Stream<List<ProductModel>> _getStream() {
    if (_searchKeyword != _lastKeyword || _selectedKategori != _lastKategori) {
      _lastKeyword = _searchKeyword;
      _lastKategori = _selectedKategori;
      _stream = _searchKeyword.isEmpty
          ? _productService.getProdukByKategori(_selectedKategori)
          : _productService.cariProduk(_searchKeyword);
    }
    return _stream!;
  }

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

  // ✅ Helper: Otomatis deteksi URL (http/https) atau Base64
  Widget _buildProductImage(String imageUrl, {double? width, required double height}) {
    if (imageUrl.isEmpty) {
      return _imgPlaceholder(width, height);
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: width ?? double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imgPlaceholder(width, height),
      );
    }

    // Base64
    try {
      return Image.memory(
        base64Decode(imageUrl),
        width: width ?? double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imgPlaceholder(width, height),
      );
    } catch (_) {
      return _imgPlaceholder(width, height);
    }
  }

  Widget _imgPlaceholder(double? width, double height) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: AppColors.inputBackground,
      child: const Center(
        child: Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.primaryGreen),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text('Katalog Produk',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryGreen)),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _searchKeyword.isNotEmpty
              ? AppColors.primaryGreen.withOpacity(0.4)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _searchKeyword.isNotEmpty
                ? AppColors.primaryGreen
                : AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) => setState(() => _searchKeyword = value),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Cari sayur segar hari ini...',
                hintStyle: AppTextStyles.inputHint,
              ),
            ),
          ),
          if (_searchKeyword.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchKeyword = '');
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textHint,
                  size: 14,
                ),
              ),
            ),
        ],
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
          : _productService.cariProdukByKategori(_searchKeyword, _selectedKategori),
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
          // ✅ FIX: Ganti ProductCard dengan card custom yang pakai _buildProductImage
          itemBuilder: (context, index) {
            final produk = produkList[index];
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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          // ✅ Pakai helper auto-detect URL/Base64
                          child: _buildProductImage(produk.imageUrl, height: 120),
                        ),
                        if (!produk.tersedia)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Container(
                                color: Colors.black.withOpacity(0.45),
                                child: const Center(
                                  child: Text(
                                    'Habis',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produk.nama,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('/ ${produk.satuan}',
                              style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Rp ${_formatHarga(produk.harga)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: produk.tersedia
                                        ? AppColors.primaryGreen
                                        : AppColors.textHint,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: produk.tersedia
                                    ? () {
                                        CartManager.instance.tambahProduk({
                                          'nama': produk.nama,
                                          'harga': produk.harga.toInt(),
                                          'satuan': produk.satuan,
                                          'imageUrl': produk.imageUrl,
                                        }, 1);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${produk.nama} ditambahkan ke keranjang!'),
                                            backgroundColor:
                                                AppColors.primaryGreen,
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: produk.tersedia
                                        ? AppColors.primaryGreen
                                        : AppColors.divider,
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
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> produk) {
    return ProductCard(
      imagePath: produk['imageUrl'],
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

  // ── CART FAB ────────────────────────────────────────
  Widget _buildCartFAB() {
    return ValueListenableBuilder<int>(
      valueListenable: CartManager.instance.jumlahNotifier,
      builder: (context, jumlah, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KeranjangBelanjaScreen()),
              ),
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.shopping_basket_rounded, color: AppColors.white),
            ),
            if (jumlah > 0)
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
                      '$jumlah',
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
      },
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}