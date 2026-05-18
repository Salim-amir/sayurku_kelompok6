import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/colors.dart';
import '../../../core/text_styles.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import 'katalog_produk_screen.dart';
import 'detail_produk_screen.dart';
import 'keranjang_belanja_screen.dart';
import '../profile/riwayat_pesanan_screen.dart';
import '../profile/dompet_digital_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/notifikasi_screen.dart';
import '../../../core/cart_manager.dart';
import 'produk_terlaris_screen.dart';

class _HeroSlide {
  final String tag;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  const _HeroSlide({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
  });
}

const _heroSlides = [
  _HeroSlide(
    tag: '🌿 Tentang SayurKu',
    title: 'Sayur Segar,\nLangsung ke Pintu',
    subtitle: 'Dipesan hari ini, dikirim besok pagi\n— segar dari kebun lokal',
    emoji: '🥦',
    gradientColors: [Color(0xFF2E7D32), Color(0xFF43A047)],
  ),
  _HeroSlide(
    tag: '⚡ Kenapa SayurKu?',
    title: '100% Sayur\nOrganik Pilihan',
    subtitle: 'Bebas pestisida, dipilih langsung\ndari mitra petani terpercaya',
    emoji: '🌱',
    gradientColors: [Color(0xFF1565C0), Color(0xFF1976D2)],
  ),
  _HeroSlide(
    tag: '💜 Komitmen Kami',
    title: 'Pesan Mudah,\nBayar Aman',
    subtitle: 'Dompet digital terintegrasi,\nriwayat pesanan real-time',
    emoji: '🛒',
    gradientColors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
  ),
];

const _kategori = [
  {
    'label': 'Sayur Hijau',
    'key': 'sayur_hijau',
    'emoji': '🥬',
    'bg': Color(0xFFE8F5E9),
  },
  {'label': 'Buah', 'key': 'buah', 'emoji': '🍎', 'bg': Color(0xFFFFF3E0)},
  {'label': 'Bumbu', 'key': 'bumbu', 'emoji': '🌶️', 'bg': Color(0xFFFCE4EC)},
  {
    'label': 'Umbi',
    'key': 'umbi_umbian',
    'emoji': '🥔',
    'bg': Color(0xFFF3E5F5),
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  StreamSubscription<List<ProductModel>>? _produkSub;

  int _currentIndex = 0;
  String _namaUser = 'Pengguna';
  List<ProductModel> _produkList = [];
  bool _produkLoading = true;

  final _pageController = PageController();
  int _heroIndex = 0;
  Timer? _slideTimer;

  @override
  void initState() {
    super.initState();
    _loadNamaUser();
    _loadProduk();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _produkSub?.cancel();
    _slideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_heroIndex + 1) % _heroSlides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _loadNamaUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _namaUser =
              doc.data()?['namaLengkap'] ??
              doc.data()?['username'] ??
              doc.data()?['nama'] ??
              'Pengguna';
        });
      }
    } catch (_) {}
  }

  void _loadProduk() {
    _produkSub = _productService.getSemuaProduk().listen(
      (list) {
        if (mounted) {
          setState(() {
            _produkList = list;
            _produkLoading = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _produkLoading = false);
      },
    );
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi ☀️';
    if (h < 15) return 'Selamat Siang 🌤️';
    if (h < 18) return 'Selamat Sore 🌥️';
    return 'Selamat Malam 🌙';
  }

  String _fmt(int harga) => harga.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  void _addToCart(ProductModel p) {
    CartManager.instance.tambahProduk({
      'nama': p.nama,
      'harga': p.harga,
      'satuan': p.satuan,
      'imageUrl': p.imageUrl,
    }, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.nama} ditambahkan ke keranjang'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goDetail(ProductModel p) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailProdukScreen(
        produk: {
          'id': p.id,
          'nama': p.nama,
          'harga': p.harga,
          'satuan': p.satuan,
          'imageUrl': p.imageUrl,
          'tersedia': p.tersedia,
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _currentIndex == 0 ? _cartFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _body(),
    );
  }

  Widget _body() {
    switch (_currentIndex) {
      case 1:
        return const RiwayatPesananScreen(showBackButton: false);
      case 2:
        return const DompetDigitalScreen(showBackButton: false);
      case 3:
        return const NotifikasiScreen(showBackButton: false);
      case 4:
        return const ProfileScreen();
      default:
        return _homeBody();
    }
  }

  Widget _homeBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _heroSliderWidget(),
                const SizedBox(height: 22),
                _sectionKategori(),
                const SizedBox(height: 22),
                _sectionTerlaris(),
                const SizedBox(height: 22),
                _sectionSegar(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────
  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 4),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      _namaUser.isNotEmpty ? _namaUser[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                    Text(
                      'Halo, $_namaUser!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 3),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KatalogProdukScreen()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFAAAAAA),
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Cari sayur segar hari ini...',
                    style: AppTextStyles.inputHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO SLIDER ────────────────────────────────────
  Widget _heroSliderWidget() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _heroSlides.length,
            onPageChanged: (i) => setState(() => _heroIndex = i),
            itemBuilder: (_, i) => _heroCard(_heroSlides[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroSlides.length,
            (i) => GestureDetector(
              onTap: () => _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _heroIndex == i ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _heroIndex == i
                      ? AppColors.primaryGreen
                      : const Color(0xFFC8DFC8),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroCard(_HeroSlide slide) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 0, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slide.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    slide.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: Center(
                child: Text(slide.emoji, style: const TextStyle(fontSize: 52)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KATEGORI ───────────────────────────────────────
  Widget _sectionKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          iconEmoji: '🗂️',
          iconBg: const Color(0xFFE8F5E9),
          title: 'Kategori',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KatalogProdukScreen()),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _kategori.asMap().entries.map((e) {
            final k = e.value;
            final isLast = e.key == _kategori.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 9),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          KatalogProdukScreen(kategoriAwal: k['key'] as String),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F4F0)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: k['bg'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              k['emoji'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          k['label'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── TERLARIS ───────────────────────────────────────
  Widget _sectionTerlaris() {
    final terlaris = _produkList.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          iconEmoji: '🔥',
          iconBg: const Color(0xFFFFF3E0),
          title: 'Produk Terlaris',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProdukTerlarisScreen()),
          ),
        ),
        const SizedBox(height: 12),
        if (_produkLoading)
          const SizedBox(
            height: 188,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 2,
              ),
            ),
          )
        else if (terlaris.isEmpty)
          const SizedBox(height: 188)
        else
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: terlaris.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _terlarisCard(terlaris[i], i),
            ),
          ),
      ],
    );
  }

  Widget _terlarisCard(ProductModel p, int rank) {
    final badgeColors = [
      const Color(0xFFF9A825),
      const Color(0xFF9E9E9E),
      const Color(0xFFA1887F),
      AppColors.primaryGreen,
      AppColors.primaryGreen,
    ];
    return GestureDetector(
      onTap: () => _goDetail(p),
      child: Container(
        width: 134,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F4F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    width: 134,
                    height: 94,
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imgPlaceholder(134, 94),
                          )
                        : _imgPlaceholder(134, 94),
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColors[rank],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '#${rank + 1} ${rank < 3 ? '🏆' : '🔥'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nama,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_fmt(p.harga)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      _addBtn(onTap: () => _addToCart(p)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PRODUK SEGAR ───────────────────────────────────
  Widget _sectionSegar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          iconEmoji: '🌿',
          iconBg: const Color(0xFFE8F5E9),
          title: 'Produk Segar',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KatalogProdukScreen()),
          ),
        ),
        const SizedBox(height: 12),
        if (_produkLoading)
          const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_produkList.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text('Belum ada produk', style: AppTextStyles.bodyMedium),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: _produkList.length,
            itemBuilder: (_, i) => _gridCard(_produkList[i]),
          ),
      ],
    );
  }

  Widget _gridCard(ProductModel p) {
    return GestureDetector(
      onTap: () => _goDetail(p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0F4F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 105,
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imgPlaceholder(null, 105),
                          )
                        : _imgPlaceholder(null, 105),
                  ),
                ),
                if (!p.tersedia)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: Text(
                            'Habis',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nama,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '/ ${p.satuan}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Rp ${_fmt(p.harga)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.tersedia
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                      _addBtn(
                        onTap: p.tersedia ? () => _addToCart(p) : null,
                        disabled: !p.tersedia,
                        size: 26,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────
  Widget _sectionHeader({
    required String iconEmoji,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(iconEmoji, style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addBtn({
    VoidCallback? onTap,
    bool disabled = false,
    double size = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFDDDDDD) : AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _imgPlaceholder(double? width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 36),
      ),
    );
  }

  // ── BOTTOM NAV ─────────────────────────────────────
  Widget _bottomNav() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: const Color(0xFFBBBBBB),
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      selectedFontSize: 10,
      unselectedFontSize: 10,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Dompet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Notifikasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }

  // ── CART FAB ───────────────────────────────────────
  Widget _cartFAB() {
    return ValueListenableBuilder<int>(
      valueListenable: CartManager.instance.jumlahNotifier,
      builder: (context, jumlah, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KeranjangBelanjaScreen(),
                  ),
                );
                setState(() {});
              },
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.shopping_basket_rounded,
                color: Colors.white,
              ),
            ),
            if (jumlah > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$jumlah',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}