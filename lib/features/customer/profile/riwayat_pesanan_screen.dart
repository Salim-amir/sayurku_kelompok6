import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../core/constants.dart';
import '../../../services/order_service.dart';
import '../../../services/product_service.dart';
import '../../../models/product_model.dart';
import '../../../core/cart_manager.dart';
import '../shop/keranjang_belanja_screen.dart';
import 'detail_pesanan_customer_screen.dart';

class RiwayatPesananScreen extends StatefulWidget {
  final bool showBackButton;
  const RiwayatPesananScreen({super.key, this.showBackButton = true});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final user = FirebaseAuth.instance.currentUser;

  late TabController _tabController;

  final List<String> _tabs = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  final Map<String, String> _tabToStatus = {
    'Menunggu': AppConstants.statusMenunggu,
    'Diproses': AppConstants.statusDiproses,
    'Dikirim': AppConstants.statusDikirim,
    'Selesai': AppConstants.statusSelesai,
    'Dibatalkan': AppConstants.statusDibatalkan,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.showBackButton ? 8 : 20, 16, 20, 0),
      child: Row(
        children: [
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.primaryGreen),
              onPressed: () => Navigator.pop(context),
            ),
          Text('Riwayat Pesanan',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── TAB BAR ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle:
            AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        indicator: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(4),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ── TAB CONTENT ─────────────────────────────────────
  Widget _buildTabContent() {
    if (user == null) {
      return const Center(child: Text('Silakan login terlebih dahulu'));
    }

    return TabBarView(
      controller: _tabController,
      children: _tabs.map((tab) {
        if (tab == 'Semua') {
          return _buildPesananList(
              _orderService.getPesananByUser(user!.uid));
        } else {
          return _buildPesananList(
              _orderService.getPesananByStatus(user!.uid, _tabToStatus[tab]!));
        }
      }).toList(),
    );
  }

  Widget _buildPesananList(Stream<List<Map<String, dynamic>>> stream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.textHint, size: 48),
                const SizedBox(height: 12),
                Text('Gagal memuat pesanan',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        final pesananList = snapshot.data ?? [];

        if (pesananList.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pesananList.length,
          itemBuilder: (context, index) {
            return _buildPesananCard(pesananList[index]);
          },
        );
      },
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              color: AppColors.textHint.withOpacity(0.4), size: 72),
          const SizedBox(height: 16),
          Text('Belum Ada Pesanan',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('Pesanan Anda akan muncul di sini',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  // ── PESANAN CARD ────────────────────────────────────
  Widget _buildPesananCard(Map<String, dynamic> pesanan) {
    final status = pesanan['status'] ?? '';
    final items = List<Map<String, dynamic>>.from(pesanan['items'] ?? []);
    final totalHarga = (pesanan['totalHarga'] ?? 0).toDouble();
    final tanggal = pesanan['tanggalPesan']?.toDate();
    final jumlahItem = items.length;
    final namaKurir = pesanan['namaKurir'];
    final noTelpKurir = pesanan['noTelpKurir'];
    final tanggalSelesai = pesanan['tanggalSelesai']?.toDate() ?? pesanan['tanggalUpdate']?.toDate() ?? tanggal;
    final tanggalDibatalkan = pesanan['tanggalDibatalkan']?.toDate() ?? pesanan['tanggalUpdate']?.toDate() ?? tanggal;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPesananCustomerScreen(pesanan: pesanan),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: tanggal + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tanggal != null ? _formatTanggal(tanggal) : '-',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),

          // Item list preview
          ...items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildProductImage(
                            item['imageUrl']?.toString() ?? '',
                            40,
                            40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${item['nama'] ?? 'Produk'} x${item['jumlah'] ?? 1}',
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),

          if (jumlahItem > 2)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+${jumlahItem - 2} produk lainnya',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint),
              ),
            ),

          const Divider(height: 20, color: AppColors.divider),

          if (namaKurir != null && namaKurir.toString().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining, color: AppColors.primaryGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kurir Pengantar', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        Text(namaKurir, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(noTelpKurir ?? '', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primaryGreen),
                    onPressed: () {
                      if (noTelpKurir != null && noTelpKurir.toString().isNotEmpty) {
                        _launchWhatsApp(noTelpKurir.toString());
                      }
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$jumlahItem produk',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              Row(
                children: [
                  Text(
                    'Rp ${_formatHarga(totalHarga.toInt())}',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryGreen, fontSize: 15),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen, size: 20),
                ],
              ),
            ],
          ),
          if (status.toLowerCase() == 'selesai' || status.toLowerCase() == 'dibatalkan') ...[
            const Divider(height: 24, color: AppColors.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    status.toLowerCase() == 'selesai'
                        ? 'Selesai pada ${tanggalSelesai != null ? _formatTanggal(tanggalSelesai) : '-'}'
                        : 'Dibatalkan pada ${tanggalDibatalkan != null ? _formatTanggal(tanggalDibatalkan) : '-'}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              OutlinedButton(
                onPressed: () async {
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)));
                  
                  bool allAdded = true;
                  int addedCount = 0;
                  final productService = ProductService();

                  for (var item in items) {
                    final id = item['id'];
                    final nama = item['nama'];
                    if ((id == null || id.toString().isEmpty) && (nama == null || nama.toString().isEmpty)) continue;
                    
                    try {
                      ProductModel? productInfo;
                      if (id != null && id.toString().isNotEmpty) {
                        productInfo = await productService.getDetailProduk(id.toString());
                      }
                      if (productInfo == null && nama != null && nama.toString().isNotEmpty) {
                        productInfo = await productService.getProdukByNama(nama.toString());
                      }
                      
                      if (productInfo != null && productInfo.tersedia && productInfo.stok > 0) {
                        int qty = item['jumlah'] ?? 1;
                        if (qty > productInfo.stok) {
                           qty = productInfo.stok;
                           allAdded = false;
                        }
                        bool success = CartManager.instance.tambahProduk({
                          'id': productInfo.id,
                          'nama': productInfo.nama,
                          'harga': productInfo.harga,
                          'satuan': productInfo.satuan,
                          'imageUrl': productInfo.imageUrl,
                          'stok': productInfo.stok,
                        }, qty);
                        if (!success) allAdded = false;
                        addedCount++;
                      } else {
                        allAdded = false;
                      }
                    } catch (e) {
                      allAdded = false;
                    }
                  }
                  
                  if (context.mounted) Navigator.pop(context);

                  if (addedCount > 0) {
                    if (!allAdded && context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                         content: Text('Beberapa produk disesuaikan/dilewati karena stok terbatas'),
                         backgroundColor: Colors.orange,
                       ));
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KeranjangBelanjaScreen(),
                        ),
                      );
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                         content: Text('Maaf, semua produk dalam pesanan ini sedang habis.'),
                         backgroundColor: Colors.red,
                    ));
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Beli Lagi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          ],
        ],
      ),
    ));
  }

  // ── STATUS BADGE ────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case AppConstants.statusMenunggu:
        bgColor = AppColors.warning.withOpacity(0.12);
        textColor = AppColors.warning;
        break;
      case AppConstants.statusDiproses:
        bgColor = AppColors.info.withOpacity(0.12);
        textColor = AppColors.info;
        break;
      case AppConstants.statusDikirim:
        bgColor = AppColors.primaryGreen.withOpacity(0.12);
        textColor = AppColors.primaryGreen;
        break;
      case AppConstants.statusSelesai:
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
        break;
      case AppConstants.statusDibatalkan:
        bgColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
        break;
      default:
        bgColor = AppColors.textHint.withOpacity(0.12);
        textColor = AppColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall
            .copyWith(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _formatTanggal(DateTime date) {
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    if (imageUrl.isEmpty) return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18);
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18),
      );
    }
    try {
      return Image.memory(
        base64Decode(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18),
      );
    } catch (_) {
      return const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    
    final url = Uri.parse('https://wa.me/$cleanPhone');
    bool launched = false;
    try {
      launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launch WA: $e');
    }
    
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstal.')),
      );
    }
  }
}
