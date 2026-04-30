import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/services/product_service.dart';
import 'package:sayurku_kelompok6/models/product_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sayurku_kelompok6/core/constants.dart';

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
  final deskripsiController = TextEditingController();

  String selectedKategori = "sayur_hijau";
  String selectedSatuan = "kg";

  File? selectedImage;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Tambah Produk"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // 📸 PILIH GAMBAR
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      if (picked != null) {
                        setStateDialog(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : Image.file(selectedImage!, fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🥬 NAMA
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Nama Produk"),
                  ),

                  const SizedBox(height: 10),

                  // 💰 HARGA
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Harga"),
                  ),

                  const SizedBox(height: 10),

                  // 📦 STOK
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Stok"),
                  ),

                  const SizedBox(height: 10),

                  // 📂 KATEGORI
                  DropdownButtonFormField(
                    value: selectedKategori,
                    items: AppConstants.kategoriProduk.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedKategori = val!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: "Kategori"),
                  ),

                  const SizedBox(height: 10),

                  // ⚖️ SATUAN
                  DropdownButtonFormField(
                    value: selectedSatuan,
                    items: AppConstants.satuanProduk.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedSatuan = val!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: "Satuan"),
                  ),

                  const SizedBox(height: 10),

                  // 📝 DESKRIPSI
                  TextField(
                    controller: deskripsiController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: "Deskripsi"),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),

              ElevatedButton(
                onPressed: () async {
                  String imageUrl = "";

                  if (selectedImage != null) {
                    imageUrl =
                        await _productService.uploadImage(selectedImage!);
                  }

                  await _productService.addProduct(
                    nama: nameController.text,
                    harga: int.parse(priceController.text),
                    stok: int.parse(stockController.text),
                    kategori: selectedKategori,
                    imageUrl: imageUrl,
                    satuan: selectedSatuan,
                    deskripsi: deskripsiController.text, // ✅ FIX
                  );

                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      );
    },
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
                deskripsi: product.deskripsi ?? "",
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