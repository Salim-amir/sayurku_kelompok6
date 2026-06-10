import 'dart:convert'; // ✅ TAMBAHAN untuk base64Decode
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import '../../../../core/cart_manager.dart';
import '../../../../models/product_model.dart';
import '../../../../services/product_service.dart';
import 'detail_produk_screen.dart';
import 'keranjang_belanja_screen.dart';

class ProdukTerlarisScreen extends StatefulWidget {
  const ProdukTerlarisScreen({super.key});

  @override
  State<ProdukTerlarisScreen> createState() => _ProdukTerlarisScreenState();
}

class _ProdukTerlarisScreenState extends State<ProdukTerlarisScreen> {
  final ProductService _productService = ProductService();

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
          children: [
            _buildAppBar(context),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.getSemuaProduk(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    );
                  }
                  final rawProdukList = snapshot.data ?? [];
                  final produkList = List<ProductModel>.from(rawProdukList)
                    ..sort((a, b) => b.terjual.compareTo(a.terjual));
                  
                  if (produkList.isEmpty) {
                    return Center(
                      child: Text('Belum ada produk',
                          style: AppTextStyles.bodyMedium),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) =>
                                DetailProdukScreen(
                              produk: {
                                'id': produk.id,
                                'nama': produk.nama,
                                'harga': produk.harga,
                                'satuan': produk.satuan,
                                'imageUrl': produk.imageUrl,
                                'tersedia': produk.tersedia,
                                'stok': produk.stok,
                                'deskripsi': produk.deskripsi,
                              },
                            ),
                            transitionsBuilder:
                                (_, animation, __, child) =>
                                    FadeTransition(
                                        opacity: animation, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 200),
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
                                    // ✅ FIX: Ganti Image.network dengan _buildProductImage
                                    child: _buildProductImage(
                                      produk.imageUrl,
                                      height: 120,
                                    ),
                                  ),
                                  if (!(produk.tersedia && produk.stok > 0))
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
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            index < 3
                                                ? Icons.emoji_events_rounded
                                                : Icons
                                                    .local_fire_department_rounded,
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
                                    Text('/ ${produk.satuan}',
                                        style: AppTextStyles.caption),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${produk.terjual} Terjual',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rp ${_formatHarga(produk.harga)}',
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                                  color: (produk.tersedia && produk.stok > 0)
                                                      ? AppColors.primaryGreen
                                                      : AppColors.textHint,
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        GestureDetector(
                                          onTap: (produk.tersedia && produk.stok > 0)
                                              ? () {
                                                  bool sukses = CartManager.instance.tambahProduk({
                                                    'id': produk.id,
                                                    'nama': produk.nama,
                                                    'harga': produk.harga,
                                                    'satuan': produk.satuan,
                                                    'imageUrl': produk.imageUrl,
                                                    'stok': produk.stok,
                                                  }, 1);

                                                  if (sukses) {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                      content: Text('${produk.nama} ditambahkan!'),
                                                      backgroundColor: AppColors.primaryGreen,
                                                      duration: const Duration(seconds: 1),
                                                    ));
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                      content: Text('Batas stok maksimal tercapai!'),
                                                      backgroundColor: Colors.orange,
                                                      duration: const Duration(seconds: 1),
                                                    ));
                                                  }
                                                }
                                              : null,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: (produk.tersedia && produk.stok > 0)
                                                  ? AppColors.primaryGreen
                                                  : AppColors.divider,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.add_rounded,
                                                color: AppColors.white,
                                                size: 18),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text('Produk Terlaris',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryGreen)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      jumlah > 99 ? '99+' : '$jumlah',
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