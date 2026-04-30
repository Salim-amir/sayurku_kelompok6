import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/services/product_service.dart';
import 'package:sayurku_kelompok6/models/product_model.dart';

class ProductStockPage extends StatefulWidget {
  const ProductStockPage({Key? key}) : super(key: key);

  @override
  State<ProductStockPage> createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ─── APP BAR ───────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'SayurKu Admin',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen),
        ),
      ),

      // ─── BODY ───────────────────────────────────────────
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getSemuaProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada produk"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  // ─── CARD ─────────────────────────────────────────────
  Widget _buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(product.nama),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rp ${product.harga}/${product.satuan}"),
            Text("Stok: ${product.stok} ${product.satuan}"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showUpdateStockDialog(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _productService.deleteProduct(product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAMBAH PRODUK ────────────────────────────────────
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await _productService.addProduct(
                nama: nameController.text,
                harga: int.parse(priceController.text),
                stok: int.parse(stockController.text),
                kategori: "sayur_hijau",
                imageUrl: "",
                satuan: "kg",
              );
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ─── UPDATE STOK ──────────────────────────────────────
  void _showUpdateStockDialog(ProductModel product) {
    final stockController = TextEditingController(text: product.stok.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Stok ${product.nama}"),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Stok Baru"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await _productService.updateProduct(
                id: product.id,
                nama: product.nama,
                harga: product.harga,
                stok: int.parse(stockController.text),
                kategori: product.kategori,
                imageUrl: product.imageUrl,
                satuan: product.satuan,
              );
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}