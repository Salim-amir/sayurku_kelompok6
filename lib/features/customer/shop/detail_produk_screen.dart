import 'dart:convert'; // ✅ TAMBAHAN untuk base64Decode seperti di home_screen
import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import '../../../../core/constants.dart';
import '../../../../core/cart_manager.dart';
import '../../../../models/product_model.dart';
import '../../../../services/product_service.dart';

class DetailProdukScreen extends StatefulWidget {
  final Map<String, dynamic> produk;
  const DetailProdukScreen({super.key, required this.produk});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  int _jumlah = 1;
  final ProductService _productService = ProductService();
  ProductModel? _produkDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
     _isLoading = false; 
    _loadDetail();
  }

  void _loadDetail() async {
    String id = widget.produk['id'] ?? '';
    
    // Fallback jika ID kosong (misal item keranjang lama)
    if (id.isEmpty) {
      final nama = widget.produk['nama'];
      if (nama != null && nama.toString().isNotEmpty) {
        final fallbackProduk = await _productService.getProdukByNama(nama);
        if (fallbackProduk != null) {
          id = fallbackProduk.id;
        }
      }
    }

    if (id.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final detail = await _productService.getDetailProduk(id);
    if (mounted) {
      setState(() {
        _produkDetail = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryGreen))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(context),
                    _buildFotoProduk(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStokBadge(),
                          const SizedBox(height: 8),
                          _buildNamaDanHarga(),
                          const SizedBox(height: 20),
                          _buildInformasiProduk(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        Text(AppConstants.appName,
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreen)),
        const SizedBox(width: 48), // biar judul tetap center
      ],
    ),
  );
}

  // ── FOTO PRODUK ─────────────────────────────────────
  Widget _buildFotoProduk() {
    final imageUrl = _produkDetail?.imageUrl ?? widget.produk['imageUrl'] ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildProductImage(imageUrl, width: double.infinity, height: 260),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FRESH HARVEST',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.white,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HELPER BARU: Diadaptasi langsung dari logika home_screen.dart
  Widget _buildProductImage(String imageUrl, {double? width, required double height}) {
    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder(width, height);
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(width, height),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(width, height),
      );
    } catch (_) {
      return _buildImagePlaceholder(width, height);
    }
  }

  // ✅ MODIFIKASI: Menambahkan parameter width & height agar sesuai dengan _buildProductImage
  Widget _buildImagePlaceholder([double? width, double? height]) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: AppColors.inputBackground,
      child: const Icon(Icons.eco_rounded,
          color: AppColors.primaryGreen, size: 80),
    );
  }

  // ── STOK BADGE ──────────────────────────────────────
  Widget _buildStokBadge() {
    final tersedia = _produkDetail?.tersedia ?? widget.produk['tersedia'] ?? true;
    final stok = _produkDetail?.stok ?? widget.produk['stok'] ?? 0;
    final satuan = _produkDetail?.satuan ?? widget.produk['satuan'] ?? '';
    final isTersedia = tersedia && stok > 0;

    return Row(
      children: [
        Icon(
          isTersedia ? Icons.verified_rounded : Icons.cancel_rounded,
          color: isTersedia ? AppColors.accentGreen : AppColors.error,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          isTersedia ? 'Stok Tersedia: $stok $satuan' : 'Stok Habis',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isTersedia ? AppColors.accentGreen : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── NAMA DAN HARGA ───────────────────────────────────
  Widget _buildNamaDanHarga() {
    final nama = _produkDetail?.nama ?? widget.produk['nama'] ?? 'Nama Produk';
    final harga = _produkDetail?.harga ?? widget.produk['harga'] ?? 0;
    final satuan = _produkDetail?.satuan ?? widget.produk['satuan'] ?? 'ikat';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nama, style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Rp ${_formatHarga(harga)}',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 6),
            Text(
              '/ $satuan',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  // ── INFORMASI PRODUK ────────────────────────────────
  Widget _buildInformasiProduk() {
    String deskripsi = _produkDetail?.deskripsi ?? widget.produk['deskripsi'] ?? '';
    if (deskripsi.trim().isEmpty) {
      deskripsi = 'Produk segar organik dipetik langsung dari petani lokal di pagi hari. Kaya akan vitamin dan mineral. Cocok untuk berbagai masakan sehari-hari.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Produk', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(
            deskripsi,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditQuantityDialog() {
    final TextEditingController qtyController = TextEditingController(text: _jumlah.toString());
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
                  final stok = _produkDetail?.stok ?? widget.produk['stok'] ?? 0;
                  final satuan = _produkDetail?.satuan ?? widget.produk['satuan'] ?? '';
                  if (newQty > stok) {
                    setState(() => _jumlah = stok);
                    final msg = stok == 0 ? 'Maaf, stok produk ini sudah habis' : 'Hanya tersedia $stok $satuan';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(msg),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                  } else {
                    setState(() => _jumlah = newQty);
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

  // ── BOTTOM BAR ──────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final tersedia = _produkDetail?.tersedia ?? widget.produk['tersedia'] ?? true;
    final stok = _produkDetail?.stok ?? widget.produk['stok'] ?? 0;
    final isTersedia = tersedia && stok > 0;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_jumlah > 1) setState(() => _jumlah--);
                  },
                  icon: const Icon(Icons.remove_rounded,
                      color: AppColors.textPrimary),
                ),
                GestureDetector(
                  onTap: _showEditQuantityDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Text('$_jumlah', style: AppTextStyles.h3),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final stok = _produkDetail?.stok ?? widget.produk['stok'] ?? 0;
                    final satuan = _produkDetail?.satuan ?? widget.produk['satuan'] ?? '';
                    if (_jumlah < stok) {
                      setState(() => _jumlah++);
                    } else {
                      final msg = stok == 0 ? 'Maaf, stok produk ini sudah habis' : 'Stok hanya tersisa $stok $satuan';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 1),
                      ));
                    }
                  },
                  icon: const Icon(Icons.add_rounded,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isTersedia
                  ? () {
                      final data = {
                        'id': _produkDetail?.id ?? widget.produk['id'],
                        'nama': _produkDetail?.nama ?? widget.produk['nama'],
                        'harga': _produkDetail?.harga ?? widget.produk['harga'],
                        'satuan': _produkDetail?.satuan ?? widget.produk['satuan'],
                        'imageUrl': _produkDetail?.imageUrl ?? widget.produk['imageUrl'],
                        'stok': _produkDetail?.stok ?? widget.produk['stok'],
                      };
                      bool sukses = CartManager.instance.tambahProduk(data, _jumlah);
                      if (sukses) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${data['nama']} ditambahkan ke keranjang!'),
                          backgroundColor: AppColors.primaryGreen,
                          duration: const Duration(seconds: 2),
                        ));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Batas stok maksimal tercapai!'),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: AppColors.divider,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Tambah ke Keranjang',
                  style: AppTextStyles.buttonPrimary),
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