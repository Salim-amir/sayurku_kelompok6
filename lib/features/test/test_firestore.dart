import 'package:flutter/material.dart';
import '../../services/product_service.dart';
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Firestore"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await ProductService().addProduct(
                nama: "Bayam Test",
                harga: 5000,
                stok: 10,
                kategori: "Sayur",
                imageUrl: "https://example.com/bayam.jpg",
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Produk berhasil ditambahkan")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          child: const Text("Tambah Produk"),
        ),
      ),
    );
  }
}