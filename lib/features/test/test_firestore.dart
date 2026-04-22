import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../core/constants.dart';
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String selectedKategori = AppConstants.kategoriSayurHijau;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedKategori,
              items: AppConstants.kategoriProduk.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKategori = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Kategori",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await ProductService().addProduct(
                  nama: "Bayam",
                  harga: 5000,
                  stok: 10,
                  kategori: selectedKategori, // ✅ dinamis
                  imageUrl: "https://example.com/bayam.jpg",
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produk berhasil ditambahkan")),
                );
              },
              child: const Text("Tambah Produk"),
            ),
          ],
        ),
      ),
    );
  }
}