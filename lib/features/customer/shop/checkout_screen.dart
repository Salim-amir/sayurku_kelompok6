import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/constants.dart';
import '../../../../core/colors.dart';
import '../../../../core/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/order_service.dart';
import '../../../../core/cart_manager.dart';
import '../../../../models/address_model.dart';
import '../../../../services/address_service.dart';
import '../profile/alamat_screen.dart';
import 'detail_produk_screen.dart';
import '../profile/konfirmasi_pembayaran_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodePembayaran = 'COD';
  final int _ongkosKirim = 10000;
  final OrderService _orderService = OrderService();
  final _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
final AddressService _addressService = AddressService();
AddressModel? _alamatUtama;

@override
void initState() {
  super.initState();
  _loadAlamatUtama();
}

void _loadAlamatUtama() async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final alamat = await _addressService.getAlamatUtama(userId);
  setState(() => _alamatUtama = alamat);
}
int get _subtotal => CartManager.instance.totalHarga;
int get _totalPembayaran => _subtotal + _ongkosKirim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlamatPengiriman(),
                    const SizedBox(height: 16),
                    _buildRingkasanPesanan(),
                    const SizedBox(height: 16),
                    _buildMetodePembayaran(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
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
          Text('Checkout',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  // ── ALAMAT PENGIRIMAN ───────────────────────────────
  Widget _buildAlamatPengiriman() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text('Alamat Pengiriman', style: AppTextStyles.h3),
              ],
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlamatScreen()),
                );
                _loadAlamatUtama();
              },
              child: Text('Ubah',
                  style: AppTextStyles.link.copyWith(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _alamatUtama == null
            ? Text('Belum ada alamat pengiriman',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_alamatUtama!.namaPenerima}   (${_alamatUtama!.nomorHp})',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _alamatUtama!.fullAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
      ],
    ),
  );
}
  // ── RINGKASAN PESANAN ───────────────────────────────
  Widget _buildRingkasanPesanan() {
final items = CartManager.instance.items;
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
          Row(
            children: [
              const Icon(Icons.shopping_basket_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text('Ringkasan Pesanan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          // List item
          ...items.map((item) => _buildItemPesanan(item)).toList(),
          const Divider(height: 24, color: AppColors.divider),
          // Subtotal & ongkir
          _buildBiayaRow('Subtotal', _subtotal),
          const SizedBox(height: 6),
          _buildBiayaRow('Ongkos Kirim', _ongkosKirim),
        ],
      ),
    );
  }

Widget _buildItemPesanan(Map<String, dynamic> item) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProdukScreen(produk: item),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.inputBackground,
              child: const Icon(Icons.image_rounded,
                  color: AppColors.textHint, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama'], style: AppTextStyles.h3),
                Text(
                  '${item['jumlah']} ${item['satuan']}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatHarga(item['harga'] * item['jumlah'])}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBiayaRow(String label, int harga) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text('Rp ${_formatHarga(harga)}', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  // ── METODE PEMBAYARAN ───────────────────────────────
Widget _buildMetodePembayaran() {
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
        Row(
          children: [
            const Icon(Icons.payment_rounded,
                color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text('Metode Pembayaran', style: AppTextStyles.h3),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetodeItem(
          icon: Icons.handshake_rounded,
          label: 'COD (Bayar di Tempat)',
          value: AppConstants.metodeCOD,
        ),
        const SizedBox(height: 8),
        _buildMetodeItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Dompet Digital SayurKu',
          value: AppConstants.metodeDompet,
        ),
      ],
    ),
  );
}

  Widget _buildMetodeItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _metodePembayaran == value;
    return GestureDetector(
      onTap: () => setState(() => _metodePembayaran = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.inputBorder,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────
Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL PEMBAYARAN',
                  style: AppTextStyles.labelUppercase.copyWith(fontSize: 10)),
              Text(
                'Rp ${_formatHarga(_totalPembayaran)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          ElevatedButton(
onPressed: _isLoading
    ? null
    : () async {
        // ── VALIDASI ──────────────────────────────
        // 1. Cek alamat
        if (_alamatUtama == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kamu belum punya alamat pengiriman! Tambahkan dulu.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // 2. Cek keranjang tidak kosong
        if (CartManager.instance.items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keranjang belanja masih kosong!'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // 3. Tampilkan dialog konfirmasi
        final konfirmasi = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Konfirmasi Pesanan', style: AppTextStyles.h3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info alamat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alamat Pengiriman',
                              style: AppTextStyles.bodySmall),
                          Text(_alamatUtama!.namaPenerima,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700)),
                          Text(_alamatUtama!.fullAddress,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                // Info pesanan
                Row(
                  children: [
                    const Icon(Icons.shopping_basket_rounded,
                        color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${CartManager.instance.totalProduk} produk',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Info metode
                Row(
                  children: [
                    const Icon(Icons.payment_rounded,
                        color: AppColors.primaryGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(_metodePembayaran, style: AppTextStyles.bodyMedium),
                  ],
                ),
                const Divider(height: 20),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Pembayaran',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      'Rp ${_formatHarga(_totalPembayaran)}',
                      style: AppTextStyles.h3
                          .copyWith(color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Ubah', style: AppTextStyles.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Ya, Pesan!', style: AppTextStyles.buttonPrimary),
              ),
            ],
          ),
        );

        // Kalau user klik Ubah / tutup dialog
        if (konfirmasi != true) return;

        // ── PROSES PESANAN ────────────────────────
        setState(() => _isLoading = true);
        try {
          await _orderService.buatPesananBaru(
            userId: _user?.uid ?? '',
            items: CartManager.instance.items,
            totalHarga: _subtotal.toDouble(),
            ongkosKirim: _ongkosKirim.toDouble(),
            metodePembayaran: _metodePembayaran,
            alamatPengiriman: _alamatUtama!.fullAddress,
          );
          setState(() => _isLoading = false);

          if (mounted) {
            final dataPesanan = {
              'totalHarga': _subtotal.toDouble(),
              'ongkosKirim': _ongkosKirim.toDouble(),
              'metodePembayaran': _metodePembayaran,
              'status': 'Menunggu Konfirmasi',
            };
            CartManager.instance.items.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    KonfirmasiPembayaranScreen(pesanan: dataPesanan),
              ),
            );
          }
        } catch (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat pesanan: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
       style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Buat Pesanan', style: AppTextStyles.buttonPrimary),
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