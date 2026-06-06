import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';
import 'package:sayurku_kelompok6/services/product_service.dart';
import 'package:sayurku_kelompok6/models/product_model.dart';
import 'dart:io';
import 'dart:convert'; // Dibutuhkan untuk base64Decode
import 'package:image_picker/image_picker.dart';
import 'package:sayurku_kelompok6/core/constants.dart';

class ProductStockPage extends StatefulWidget {
  const ProductStockPage({Key? key}) : super(key: key);

  @override
  State<ProductStockPage> createState() => _ProductStockPageState();
}

class _ProductStockPageState extends State<ProductStockPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  String _selectedStockFilter = 'Semua';
  final List<String> _stockFilters = ['Semua', 'Stok Habis', 'Stok Menipis', 'Stok Aman'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper untuk menampilkan icon jika gambar error
  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.image_outlined,
      size: 60,
      color: AppColors.textHint,
    );
  }

  // ─── FUNGSI FILTER PRODUK BERDASARKAN PENCARIAN & STOK ─────
  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedStockFilter == 'Stok Habis') {
      filtered = filtered.where((p) => p.stok == 0).toList();
    } else if (_selectedStockFilter == 'Stok Menipis') {
      filtered = filtered.where((p) => p.stok > 0 && p.stok < 10).toList();
    } else if (_selectedStockFilter == 'Stok Aman') {
      filtered = filtered.where((p) => p.stok >= 10).toList();
    }

    return filtered;
  }

  Widget _buildStockFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _stockFilters.map((filter) {
          final isSelected = _selectedStockFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStockFilter = filter);
                }
              },
              selectedColor: AppColors.primaryGreen,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : AppColors.inputBorder,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ─── APP BAR ───────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Manajemen Produk',
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
        ),
        centerTitle: false,
      ),

      // ─── BODY ───────────────────────────────────────────
      body: CustomScrollView(
        slivers: [
          // Header & Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola ketersediaan sayur segar hari ini dengan mudah dan cepat.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  
                  // Full-width Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? AppColors.primaryGreen.withOpacity(0.4)
                            : AppColors.inputBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onSubmitted: (value) {
                        setState(() => _searchQuery = value);
                      },
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari nama sayuran...',
                        hintStyle: AppTextStyles.inputHint,
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _searchQuery.isNotEmpty ? AppColors.primaryGreen : AppColors.textHint,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.textHint.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 14),
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStockFilterChips(),
                ],
              ),
            ),
          ),

          // Product List
          StreamBuilder<List<ProductModel>>(
            stream: _productService.getAdminSemuaProduk(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Belum ada produk', style: AppTextStyles.h3),
                    ),
                  ),
                );
              }

              final allProducts = snapshot.data!;
              final filteredProducts = _filterProducts(allProducts);

              if (filteredProducts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 60,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Produk tidak ditemukan',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba sesuaikan filter atau pencarianmu',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildProductCard(filteredProducts[index]),
                    );
                  }, childCount: filteredProducts.length),
                ),
              );
            },
          ),

          // Padding ekstra di bawah agar card terakhir tidak tertutup FAB
          SliverToBoxAdapter(child: const SizedBox(height: 100)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  // ─── PRODUCT CARD WIDGET ────────────────────────────────
  Widget _buildProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail Gambar ──
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: () {
                      if (product.imageUrl.startsWith('http://') ||
                          product.imageUrl.startsWith('https://')) {
                        return Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderIcon(),
                        );
                      } else {
                        try {
                          return Image.memory(
                            base64Decode(product.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderIcon(),
                          );
                        } catch (e) {
                          return _buildPlaceholderIcon();
                        }
                      }
                    }(),
                  )
                : _buildPlaceholderIcon(),
          ),
          const SizedBox(width: 14),

          // ── Detail Produk ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.nama,
                        style: AppTextStyles.h3.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showUpdateProductDialog(product);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(product);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text('Edit', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 18, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text('Hapus', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert, color: AppColors.textHint, size: 20),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.kategori.replaceAll('_', ' ').toUpperCase(),
                        style: AppTextStyles.labelLink.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${product.harga.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}/${product.satuan}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                
                // ── Kontrol Stok ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sisa Stok:', style: AppTextStyles.bodySmall),
                    Row(
                      children: [
                        _buildQuickStockButton(
                          icon: Icons.remove,
                          color: AppColors.error,
                          onTap: () {
                            if (product.stok > 0) {
                              _productService.updateStok(product.id, product.stok - 1);
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showEditStockDialog(product),
                          child: Container(
                            width: 46,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                            ),
                            child: Text(
                              product.stok.toString(),
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 14, 
                                color: AppColors.primaryGreen
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStockButton(
                          icon: Icons.add,
                          color: AppColors.primaryGreen,
                          onTap: () {
                            _productService.updateStok(product.id, product.stok + 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStockButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showEditStockDialog(ProductModel product) {
    final TextEditingController stockController =
        TextEditingController(text: product.stok.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Ubah Stok Manual', style: AppTextStyles.h3),
          content: TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Sisa Stok',
              hintText: 'Masukkan angka',
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
                int? newStock = int.tryParse(stockController.text);
                if (newStock != null && newStock >= 0) {
                  _productService.updateStok(product.id, newStock);
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

  // ─── BOTTOM SHEET TAMBAH PRODUK ───────────────────────────
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final deskripsiController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String selectedKategori = "sayur_hijau";
    String selectedSatuan = "kg";
    File? selectedImage;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            // Biar form naik saat keyboard muncul
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // ── Header Laci ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tambah Produk Baru', style: AppTextStyles.h2),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
                  
                  // ── Isi Form ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Gambar Produk ──
                            if (selectedImage == null)
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.inputBorder),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 48,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Pilih Gambar Produk', style: AppTextStyles.bodyMedium),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: FileImage(selectedImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        imageQuality: 50,
                                      );
                                      if (image != null) {
                                        setStateSheet(() {
                                          selectedImage = File(image.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                                    label: Text(selectedImage == null ? 'Galeri' : 'Ubah', style: AppTextStyles.buttonPrimary),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGreen,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker.pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        imageQuality: 50,
                                      );
                                      if (image != null) {
                                        setStateSheet(() {
                                          selectedImage = File(image.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                    label: Text('Kamera', style: AppTextStyles.buttonPrimary),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGreen,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── Nama Sayuran ──
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Nama Sayuran',
                                labelStyle: AppTextStyles.bodyMedium,
                                hintText: 'Contoh: Bayam Hijau',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                            ),

                            const SizedBox(height: 16),

                            // ── Harga ──
                            TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Harga per $selectedSatuan',
                                labelStyle: AppTextStyles.bodyMedium,
                                prefixText: 'Rp ',
                                suffixText: '/ $selectedSatuan',
                                suffixStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) => value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
                            ),

                            const SizedBox(height: 16),

                            // ── Stok Awal + Satuan ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: stockController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Stok Awal',
                                      labelStyle: AppTextStyles.bodyMedium,
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.inputBackground,
                                    ),
                                    style: AppTextStyles.inputText,
                                    validator: (value) => value == null || value.isEmpty ? 'Stok tidak boleh kosong' : null,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedSatuan,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Satuan',
                                      labelStyle: AppTextStyles.bodyMedium,
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.inputBackground,
                                    ),
                                    items: AppConstants.satuanProduk.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (value) => setStateSheet(() => selectedSatuan = value!),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Kategori ──
                            DropdownButtonFormField<String>(
                              value: selectedKategori,
                              items: AppConstants.kategoriProduk.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                              onChanged: (value) => setStateSheet(() => selectedKategori = value!),
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                                labelStyle: AppTextStyles.bodyMedium,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Deskripsi ──
                            TextFormField(
                              controller: deskripsiController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Deskripsi Sayuran',
                                labelStyle: AppTextStyles.bodyMedium,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Tombol Aksi Bawah (Sticky) ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (formKey.currentState!.validate()) {
                            setStateSheet(() => isLoading = true);
                            try {
                              String base64ImageString = "";
                              if (selectedImage != null) {
                                base64ImageString = await _productService.uploadImage(selectedImage!);
                              }
                              await _productService.addProduct(
                                nama: nameController.text,
                                harga: int.parse(priceController.text),
                                stok: int.parse(stockController.text),
                                kategori: selectedKategori,
                                imageUrl: base64ImageString,
                                satuan: selectedSatuan,
                                deskripsi: deskripsiController.text,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Produk berhasil ditambahkan!'), backgroundColor: AppColors.success),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                              );
                            } finally {
                              // We only set to false if the widget is still mounted, but bottom sheet pop handles it anyway
                              if (context.mounted) setStateSheet(() => isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isLoading 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                              ) 
                            : Text('Simpan Produk', style: AppTextStyles.buttonPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── BOTTOM SHEET UPDATE PRODUK ──────────────────────────────
  void _showUpdateProductDialog(ProductModel product) {
    final namaController = TextEditingController(text: product.nama);
    final hargaController = TextEditingController(text: product.harga.toString());
    final deskripsiController = TextEditingController(text: product.deskripsi);
    final formKey = GlobalKey<FormState>();

    String selectedKategori = product.kategori;
    String selectedSatuan = product.satuan;
    File? updatedImage;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // ── Header Laci ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit Produk', style: AppTextStyles.h2),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
                  
                  // ── Isi Form ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Gambar Produk ──
                            if (updatedImage == null && product.imageUrl.isEmpty)
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: AppColors.inputBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.inputBorder),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.image_outlined, size: 48, color: AppColors.textHint),
                                    const SizedBox(height: 12),
                                    Text('Belum Ada Gambar', style: AppTextStyles.bodyMedium),
                                  ],
                                ),
                              )
                            else if (updatedImage != null)
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: FileImage(updatedImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (product.imageUrl.isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: product.imageUrl.startsWith('http')
                                      ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon())
                                      : Image.memory(base64Decode(product.imageUrl), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon()),
                                ),
                              ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        imageQuality: 50,
                                      );
                                      if (image != null) {
                                        setStateSheet(() {
                                          updatedImage = File(image.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                                    label: Text('Galeri', style: AppTextStyles.buttonPrimary),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGreen,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker.pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 400,
                                        maxHeight: 400,
                                        imageQuality: 50,
                                      );
                                      if (image != null) {
                                        setStateSheet(() {
                                          updatedImage = File(image.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                    label: Text('Kamera', style: AppTextStyles.buttonPrimary),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentGreen,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── Nama Sayuran ──
                            TextFormField(
                              controller: namaController,
                              decoration: InputDecoration(
                                labelText: 'Nama Sayuran',
                                labelStyle: AppTextStyles.bodyMedium,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                            ),

                            const SizedBox(height: 16),

                            // ── Harga ──
                            TextFormField(
                              controller: hargaController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Harga per $selectedSatuan',
                                labelStyle: AppTextStyles.bodyMedium,
                                prefixText: 'Rp ',
                                suffixText: '/ $selectedSatuan',
                                suffixStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                              validator: (value) => value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
                            ),

                            const SizedBox(height: 16),

                            // ── Kategori & Satuan ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedKategori,
                                    items: AppConstants.kategoriProduk.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                                    onChanged: (value) => setStateSheet(() => selectedKategori = value!),
                                    decoration: InputDecoration(
                                      labelText: 'Kategori',
                                      labelStyle: AppTextStyles.bodyMedium,
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(12))),
                                      filled: true,
                                      fillColor: AppColors.inputBackground,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedSatuan,
                                    items: AppConstants.satuanProduk.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (value) => setStateSheet(() => selectedSatuan = value!),
                                    decoration: InputDecoration(
                                      labelText: 'Satuan',
                                      labelStyle: AppTextStyles.bodyMedium,
                                      border: const OutlineInputBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(12))),
                                      filled: true,
                                      fillColor: AppColors.inputBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Deskripsi ──
                            TextFormField(
                              controller: deskripsiController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Deskripsi Sayuran',
                                labelStyle: AppTextStyles.bodyMedium,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                              ),
                              style: AppTextStyles.inputText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Tombol Aksi Bawah (Sticky) ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (formKey.currentState!.validate()) {
                            setStateSheet(() => isLoading = true);
                            try {
                              String base64ImageString = product.imageUrl;
                              if (updatedImage != null) {
                                base64ImageString = await _productService.uploadImage(updatedImage!);
                              }

                              await _productService.updateProduct(
                                id: product.id,
                                nama: namaController.text,
                                harga: int.parse(hargaController.text),
                                stok: product.stok,
                                kategori: selectedKategori,
                                imageUrl: base64ImageString,
                                satuan: selectedSatuan,
                                deskripsi: deskripsiController.text,
                              );

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('Produk berhasil diupdate!'), backgroundColor: AppColors.success),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                              );
                            } finally {
                              if (context.mounted) setStateSheet(() => isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isLoading 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                              ) 
                            : Text('Simpan Perubahan', style: AppTextStyles.buttonPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── DIALOG UPDATE STOK ────────────────────────────────
  void _showUpdateStockDialog(ProductModel product) {
    final stokController =
        TextEditingController(text: product.stok.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          'Update Stok - ${product.nama}',
          style: AppTextStyles.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // ✅ Info satuan produk ditampilkan sebagai konteks
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Satuan produk: ${product.satuan}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ✅ suffixText otomatis menggunakan satuan dari produk
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah stok',
                labelText: 'Jumlah Stok',
                labelStyle: AppTextStyles.bodySmall,
                // suffix menampilkan satuan asli produk (gram, ikat, kg, dll)
                suffixText: product.satuan,
                suffixStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
              ),
              style: AppTextStyles.inputText,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: AppTextStyles.link),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock =
                  int.tryParse(stokController.text) ?? 0;

              await _productService.updateProduct(
                id: product.id,
                nama: product.nama,
                harga: product.harga,
                stok: newStock,
                kategori: product.kategori,
                imageUrl: product.imageUrl,
                satuan: product.satuan,
                deskripsi: product.deskripsi,
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Simpan',
                style: AppTextStyles.buttonPrimary),
          ),
        ],
      ),
    );
  }

  // ─── DELETE PRODUCT ───────────────────────────────────
  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                  ),
                  const SizedBox(width: 12),
                  Text('Hapus Produk', style: AppTextStyles.h3),
                ],
              ),
              content: Text(
                'Apakah Anda yakin ingin menghapus "${product.nama}"?\nTindakan ini tidak dapat dibatalkan.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text('Batal', style: AppTextStyles.link.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.error.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: isLoading ? null : () async {
                    setStateDialog(() => isLoading = true);
                    try {
                      await _productService.deleteProduct(product.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.white),
                                const SizedBox(width: 12),
                                Expanded(child: Text('"${product.nama}" berhasil dihapus')),
                              ],
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setStateDialog(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : const Text('Ya, Hapus', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}