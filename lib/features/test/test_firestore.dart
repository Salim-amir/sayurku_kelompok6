import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/product_service.dart';
import '../../../core/constants.dart';

class TambahProdukScreen extends StatefulWidget {
  const TambahProdukScreen({super.key});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String selectedKategori = AppConstants.kategoriSayurHijau;
  String selectedSatuan = AppConstants.satuanProduk[0];

  File? selectedImage;

  final ProductService _productService = ProductService();

  bool isLoading = false;

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // 🚀 SIMPAN PRODUK
  Future<void> simpanProduk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String imageUrl = "";

      if (selectedImage != null) {
        imageUrl = await _productService.uploadImage(selectedImage!);
      }

      await _productService.addProduct(
        nama: _namaController.text,
        harga: int.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
        kategori: selectedKategori,
        imageUrl: imageUrl,
        satuan: selectedSatuan,
        deskripsi: _deskripsiController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil ditambahkan")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📸 IMAGE PREVIEW
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : Image.file(selectedImage!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 16),

              // 🥬 NAMA
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (value) =>
                    value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),

              const SizedBox(height: 12),

              // 💰 HARGA
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga"),
                validator: (value) =>
                    value!.isEmpty ? "Harga wajib diisi" : null,
              ),

              const SizedBox(height: 12),

              // 📦 STOK
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stok"),
                validator: (value) =>
                    value!.isEmpty ? "Stok wajib diisi" : null,
              ),

              const SizedBox(height: 12),

              // 📂 KATEGORI
              DropdownButtonFormField(
                value: selectedKategori,
                items: AppConstants.kategoriProduk.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedKategori = value!);
                },
                decoration: const InputDecoration(labelText: "Kategori"),
              ),

              const SizedBox(height: 12),

              // ⚖️ SATUAN
              DropdownButtonFormField(
                value: selectedSatuan,
                items: AppConstants.satuanProduk.map((satuan) {
                  return DropdownMenuItem(
                    value: satuan,
                    child: Text(satuan),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSatuan = value!);
                },
                decoration: const InputDecoration(labelText: "Satuan"),
              ),

              const SizedBox(height: 12),

              // 📝 DESKRIPSI
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),

              const SizedBox(height: 20),

              // 🚀 BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : simpanProduk,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Simpan Produk"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}