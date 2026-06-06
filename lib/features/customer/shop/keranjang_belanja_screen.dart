import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import '../../../../core/cart_manager.dart';
import 'checkout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_produk_screen.dart';

class KeranjangBelanjaScreen extends StatefulWidget {
  const KeranjangBelanjaScreen({super.key});

  @override
  State<KeranjangBelanjaScreen> createState() => _KeranjangBelanjaScreenState();
}

class _KeranjangBelanjaScreenState extends State<KeranjangBelanjaScreen> {
  List<Map<String, dynamic>> get _keranjang => CartManager.instance.items;
  int get _totalHarga => CartManager.instance.totalHarga;
  int get _totalProduk => CartManager.instance.totalProduk;

  @override
    void initState() {
      super.initState();
      CartManager.instance.jumlahNotifier.addListener(_refreshKeranjang);
    }

    @override
    void dispose() {
      CartManager.instance.jumlahNotifier.removeListener(_refreshKeranjang);
      super.dispose();
    }

    void _refreshKeranjang() {
      if (mounted) setState(() {});
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PESANAN ANDA', style: AppTextStyles.labelUppercase),
                  const SizedBox(height: 4),
                  Text('Panen Segar\nHari Ini.',
                      style: AppTextStyles.h1.copyWith(fontSize: 28)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _keranjang.isEmpty
                  ? _buildKeranjangKosong()
                  : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: _keranjang.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildItemKeranjang(index),
                  ),
            ),
            if (_keranjang.isNotEmpty) _buildBottomBar(context),
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
          Text('Keranjang',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  void _showEditQuantityDialog(int index, int currentQty) {
    final TextEditingController qtyController = TextEditingController(text: currentQty.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ubah Jumlah', style: AppTextStyles.h3),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Jumlah',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.inputBackground,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                int? newQty = int.tryParse(qtyController.text);
                if (newQty != null && newQty > 0) {
                  final stok = currentQty; // Wait, currentQty is just currentQty. Let's get stok from _keranjang[index] instead inside the dialog or just use the current index? 
                  // Let's pass the item directly instead of currentQty. Actually I can just look up _keranjang[index]['stok'].
                  final int stokLimit = CartManager.instance.items[index]['stok'] ?? 999;
                  final String satuan = CartManager.instance.items[index]['satuan'] ?? '';
                  if (newQty > stokLimit) {
                    setState(() => CartManager.instance.updateJumlah(index, stokLimit));
                    final msg = stokLimit == 0 ? 'Maaf, stok produk ini sudah habis' : 'Hanya tersedia $stokLimit $satuan';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(msg),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                  } else {
                    setState(() => CartManager.instance.updateJumlah(index, newQty));
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ── ITEM KERANJANG ───────────────────────────────────
Widget _buildItemKeranjang(int index) {
  final item = _keranjang[index];
  final imageUrl = item['imageUrl'] ?? '';

    return GestureDetector(
  onTap: () => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => DetailProdukScreen(
        produk: {
          'id': item['id'] ?? '',
          'nama': item['nama'],
          'harga': item['harga'],
          'satuan': item['satuan'],
          'imageUrl': item['imageUrl'] ?? '',
          'tersedia': true,
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ),
      child: Container(
        padding: const EdgeInsets.all(12),
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
    child: Row(
      children: [
        // Foto produk
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _buildProductImage(imageUrl, 85, 85),
        ),
        const SizedBox(width: 14),
        // Info produk
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['nama'],
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                'Rp ${_formatHarga(item['harga'])} / ${item['satuan']}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Tombol kurangi
                  _buildQtyButton(
                    icon: Icons.remove_rounded,
                    onTap: () => setState(() =>
                        CartManager.instance.updateJumlah(
                            index, item['jumlah'] - 1)),
                  ),
                  // Jumlah
                  GestureDetector(
                    onTap: () => _showEditQuantityDialog(index, item['jumlah']),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.2)),
                      ),
                      child: Text('${item['jumlah']}',
                          style: AppTextStyles.h3.copyWith(
                              color: AppColors.primaryGreen)),
                    ),
                  ),
                  // Tombol tambah
                  _buildQtyButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      final stok = item['stok'] ?? 999;
                      final satuan = item['satuan'] ?? '';
                      if (item['jumlah'] < stok) {
                        setState(() => CartManager.instance.updateJumlah(index, item['jumlah'] + 1));
                      } else {
                        final msg = stok == 0 ? 'Maaf, stok produk ini sudah habis' : 'Stok hanya tersisa $stok $satuan';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(msg),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 1),
                        ));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Kolom kanan — total + hapus
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () =>
                  setState(() => CartManager.instance.hapusProduk(index)),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rp ${_formatHarga(item['harga'] * item['jumlah'])}',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700),
           ),
          ],
        ),       
      ],
    ),           
  ),             
);               
}              

Widget _buildFotoPlaceholder() {
  return Container(
    width: 85,
    height: 85,
    decoration: BoxDecoration(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.eco_rounded,
        color: AppColors.primaryGreen, size: 36),
  );
}

Widget _buildProductImage(String imageUrl, double width, double height) {
  if (imageUrl.isEmpty) return _buildFotoPlaceholder();
  if (imageUrl.startsWith('http')) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFotoPlaceholder(),
    );
  }
  try {
    return Image.memory(
      base64Decode(imageUrl),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFotoPlaceholder(),
    );
  } catch (_) {
    return _buildFotoPlaceholder();
  }
}
  Widget _buildQtyButton(
    {required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Icon(icon, size: 16, color: AppColors.primaryGreen),
    ),
  );
}

  // ── KERANJANG KOSONG ────────────────────────────────
  Widget _buildKeranjangKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_basket_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Keranjang masih kosong', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          Text('Yuk tambahkan sayuran segar!',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Estimasi',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                  Text(
                    'Rp ${_formatHarga(_totalHarga)}',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_totalProduk PRODUK',
                  style: AppTextStyles.labelUppercase.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const SizedBox(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lanjut ke Pembayaran',
                      style: AppTextStyles.buttonPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}