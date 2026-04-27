import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';

class ProductStockPage extends StatefulWidget {
  const ProductStockPage({Key? key}) : super(key: key);

  @override
  State<ProductStockPage> createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  // Sample data produk
  final List<ProductModel> products = [
    ProductModel(
      id: 1,
      name: 'Bayam Hijau',
      price: 12000,
      stock: 45,
      image: 'assets/images/bayam.jpg',
      category: 'ORGANIC',
    ),
    ProductModel(
      id: 2,
      name: 'Tomat Merah',
      price: 18500,
      stock: 120,
      image: 'assets/images/tomat.jpg',
      category: 'ORGANIC',
    ),
    ProductModel(
      id: 3,
      name: 'Wortel Medan',
      price: 15000,
      stock: 85,
      image: 'assets/images/wortel.jpg',
      category: 'FRESH',
    ),
    ProductModel(
      id: 4,
      name: 'Cabai Merah',
      price: 45000,
      stock: 12,
      image: 'assets/images/cabai.jpg',
      category: 'FRESH',
    ),
    ProductModel(
      id: 5,
      name: 'Brokoli Segar',
      price: 22000,
      stock: 56,
      image: 'assets/images/brokoli.jpg',
      category: 'ORGANIC',
    ),
    ProductModel(
      id: 6,
      name: 'Kubis Putih',
      price: 8500,
      stock: 145,
      image: 'assets/images/kubis.jpg',
      category: 'FRESH',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ─── APP BAR ───────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: Text(
          'SayurKu Admin',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 140,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Produk...',
                  hintStyle: AppTextStyles.inputHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textHint,
                    size: 18,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.inputBorder,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                ),
              ),
            ),
          ),
        ],
      ),
      // ─── BODY ───────────────────────────────────────────
      body: CustomScrollView(
        slivers: [
          // ─ Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Produk & Stok',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola ketersediaan produk pertanian hari ini',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ─ Product List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildProductCard(product),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
          // ─ Bottom Spacing
          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),
        ],
      ),
      // ─── FLOATING ACTION BUTTON ─────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah Produk Baru')),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      // ─────────────────────────────────────────────────────
      // PENTING: TIDAK ADA bottomNavigationBar DI SINI
      // Navigation diatur oleh parent AdminDashboard
      // ─────────────────────────────────────────────────────
    );
  }

  // ─── PRODUCT CARD WIDGET ────────────────────────────────
  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Product Image with Badge
          Stack(
            children: [
              // Image placeholder
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 60,
                  color: AppColors.textHint,
                ),
              ),
              // Category Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category,
                    style: AppTextStyles.labelLink.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ─ Product Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─ Name and Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} dihapus'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // ─ Price
                Text(
                  'Rp ${product.price.toString().replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => '${match.group(1)}.',
                      )}/kg',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                // ─ Stock Input Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STOK:',
                        style: AppTextStyles.labelUppercase,
                      ),
                      Row(
                        children: [
                          Text(
                            product.stock.toString(),
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'kg',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ─ Update Stock Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showUpdateStockDialog(product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update Stok',
                      style: AppTextStyles.buttonPrimary.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── DIALOG UPDATE STOCK ────────────────────────────────
  void _showUpdateStockDialog(ProductModel product) {
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          'Update Stok - ${product.name}',
          style: AppTextStyles.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah stok',
                hintStyle: AppTextStyles.inputHint,
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.inputBorder,
                  ),
                ),
              ),
              style: AppTextStyles.inputText,
            ),
            const SizedBox(height: 16),
            Text(
              'Stok saat ini: ${product.stock} kg',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.link,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text) ?? 0;
              setState(() {
                product.stock = newStock;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stok ${product.name} berhasil diupdate ke $newStock kg',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Simpan',
              style: AppTextStyles.buttonPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ─────────── PRODUCT MODEL ──────────────────────────────
// ─────────────────────────────────────────────────────────

class ProductModel {
  final int id;
  final String name;
  final int price;
  int stock;
  final String image;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.category,
  });
}