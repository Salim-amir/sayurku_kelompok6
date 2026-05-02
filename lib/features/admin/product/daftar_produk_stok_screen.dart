import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
          StreamBuilder<List<ProductModel>>(
            stream: _productService.getSemuaProduk(),
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
                      child: Text(
                        'Belum ada produk',
                        style: AppTextStyles.h3,
                      ),
                    ),
                  ),
                );
              }

              final products = snapshot.data!;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildProductCard(products[index]),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),

          // ─ Bottom Spacing
          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),
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
              // ✅ Image dari URL atau Placeholder
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: product.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Error handling untuk image load
                            debugPrint('Error loading image: $exception');
                          },
                        )
                      : null,
                ),
                child: product.imageUrl.isEmpty
                    ? Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: AppColors.textHint,
                      )
                    : null,
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
                    product.kategori,
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
                // ─ Name and Menu Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.nama,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    PopupMenuButton(
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
                              Text(
                                'Edit',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ─ Price
                Text(
                  'Rp ${product.harga.toString().replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => '${match.group(1)}.',
                      )}/${product.satuan}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 8),

                // ─ Description (jika ada)
                if (product.deskripsi.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      product.deskripsi,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                            product.stok.toString(),
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.satuan,
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

  // ─── DIALOG TAMBAH PRODUK ───────────────────────────
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final deskripsiController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String selectedKategori = "sayur_hijau";
    String selectedSatuan = "kg";

    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: Text(
                'Tambah Produk Baru',
                style: AppTextStyles.h3,
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),

                      // ✅ SECTION PILIH GAMBAR
                      if (selectedImage == null)
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pilih Gambar Produk',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ✅ BUTTON PILIH/UBAH GAMBAR
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image =
                                    await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  setStateDialog(() {
                                    selectedImage = File(image.path);
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                selectedImage == null ? 'Galeri' : 'Ubah',
                                style: AppTextStyles.buttonPrimary
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image =
                                    await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (image != null) {
                                  setStateDialog(() {
                                    selectedImage = File(image.path);
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Kamera',
                                style: AppTextStyles.buttonPrimary
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ─ Nama Produk
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Sayuran',
                          labelStyle: AppTextStyles.bodySmall,
                          hintText: 'Contoh: Bayam Hijau',
                          hintStyle: AppTextStyles.inputHint,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama produk tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ─ Harga Produk
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga per kg',
                          labelStyle: AppTextStyles.bodySmall,
                          prefixText: 'Rp ',
                          hintText: 'Contoh: 12000',
                          hintStyle: AppTextStyles.inputHint,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ─ Stok Produk
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stok Awal',
                          labelStyle: AppTextStyles.bodySmall,
                          suffixText: 'kg',
                          hintText: 'Contoh: 45',
                          hintStyle: AppTextStyles.inputHint,
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        style: AppTextStyles.inputText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Stok tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Stok harus berupa angka';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ─ Kategori
                      DropdownButtonFormField<String>(
                        value: selectedKategori,
                        items: AppConstants.kategoriProduk.map((kategori) {
                          return DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedKategori = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ─ Satuan
                      DropdownButtonFormField<String>(
                        value: selectedSatuan,
                        items: AppConstants.satuanProduk.map((satuan) {
                          return DropdownMenuItem(
                            value: satuan,
                            child: Text(satuan),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedSatuan = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ─ Deskripsi
                      TextFormField(
                        controller: deskripsiController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Sayuran',
                          labelStyle: AppTextStyles.bodySmall,
                          hintText:
                              'Ketikkan informasi tentang sayuran ini...',
                          hintStyle: AppTextStyles.inputHint,
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
                ),
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
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        String imageUrl = "";

                        // ✅ Upload gambar jika ada
                        if (selectedImage != null && !kIsWeb) {
                          imageUrl = await _productService
                              .uploadImage(selectedImage!);
                        }

                        await _productService.addProduct(
                          nama: nameController.text,
                          harga: int.parse(priceController.text),
                          stok: int.parse(stockController.text),
                          kategori: selectedKategori,
                          imageUrl: imageUrl,
                          satuan: selectedSatuan,
                          deskripsi: deskripsiController.text,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Produk "${nameController.text}" berhasil ditambahkan!',
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Simpan Produk',
                    style: AppTextStyles.buttonPrimary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── DIALOG UPDATE PRODUK ──────────────────────────────
  void _showUpdateProductDialog(ProductModel product) {
    final namaController = TextEditingController(text: product.nama);
    final hargaController =
        TextEditingController(text: product.harga.toString());
    final deskripsiController =
        TextEditingController(text: product.deskripsi);
    final formKey = GlobalKey<FormState>();

    String selectedKategori = product.kategori;
    String selectedSatuan = product.satuan;
    File? selectedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            title: Text(
              'Edit Produk - ${product.nama}',
              style: AppTextStyles.h3,
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),

                    // ✅ SECTION GAMBAR YANG BISA DIUBAH
                    if (selectedImage == null && product.imageUrl.isEmpty)
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih Gambar Produk',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      )
                    else if (selectedImage != null)
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else if (product.imageUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setModalState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                              Icon(
                                Icons.edit,
                                color: AppColors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ✅ BUTTON UBAH/HAPUS GAMBAR
                    if (selectedImage != null || product.imageUrl.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image =
                                    await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  setModalState(() {
                                    selectedImage = File(image.path);
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Ubah Gambar',
                                style: AppTextStyles.buttonPrimary
                                    .copyWith(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                selectedImage = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Hapus',
                              style: AppTextStyles.buttonPrimary
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setModalState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pilih Gambar',
                          style: AppTextStyles.buttonPrimary
                              .copyWith(fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ─ Nama
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Sayuran',
                        labelStyle: AppTextStyles.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: AppTextStyles.inputText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ─ Harga
                    TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        labelStyle: AppTextStyles.bodySmall,
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: AppTextStyles.inputText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // ─ Kategori
                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      items: AppConstants.kategoriProduk.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedKategori = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ─ Satuan
                    DropdownButtonFormField<String>(
                      value: selectedSatuan,
                      items: AppConstants.satuanProduk.map((satuan) {
                        return DropdownMenuItem(
                          value: satuan,
                          child: Text(satuan),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedSatuan = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ─ Deskripsi
                    TextFormField(
                      controller: deskripsiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Sayuran',
                        labelStyle: AppTextStyles.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: AppTextStyles.inputText,
                    ),
                  ],
                ),
              ),
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
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      String imageUrl = product.imageUrl;

                      // ✅ Upload gambar baru jika ada
                      if (selectedImage != null && !kIsWeb) {
                        imageUrl = await _productService
                            .uploadImage(selectedImage!);
                      }

                      await _productService.updateProduct(
                        id: product.id,
                        nama: namaController.text,
                        harga: int.parse(hargaController.text),
                        stok: product.stok,
                        kategori: selectedKategori,
                        imageUrl: imageUrl,
                        satuan: selectedSatuan,
                        deskripsi: deskripsiController.text,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Produk "${namaController.text}" berhasil diupdate!',
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Perubahan',
                  style: AppTextStyles.buttonPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── DIALOG UPDATE STOK ────────────────────────────────
  void _showUpdateStockDialog(ProductModel product) {
    final stokController = TextEditingController(
      text: product.stok.toString(),
    );

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
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah stok',
                hintStyle: AppTextStyles.inputHint,
                suffixText: product.satuan,
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
              'Stok saat ini: ${product.stok} ${product.satuan}',
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
            onPressed: () async {
              final newStock = int.tryParse(stokController.text) ?? 0;

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

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stok ${product.nama} berhasil diupdate ke $newStock ${product.satuan}',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
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

  // ─── DELETE PRODUCT ───────────────────────────────────
  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          'Hapus Produk?',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${product.nama}"?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Batal',
              style: AppTextStyles.link,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await _productService.deleteProduct(product.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${product.nama} berhasil dihapus',
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}