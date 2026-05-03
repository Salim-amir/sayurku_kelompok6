import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../core/constants.dart';

// ─── Product Card ─────────────────────────────────────────────────────────────
/// Kartu produk untuk ditampilkan di halaman katalog / home.
/// Mendukung tampilan grid (vertikal) dan list (horizontal).
///
/// Contoh penggunaan:
/// ```dart
/// ProductCard(
///   imagePath: 'assets/images/bayam.jpg',
///   name: 'Bayam Organik',
///   price: 5000,
///   unit: 'ikat',
///   isAvailable: true,
///   onTap: () {},
///   onAddToCart: () {},
/// )
/// ```
class ProductCard extends StatelessWidget {
  final String? imagePath;
  final String name;
  final int price;
  final String unit;
  final bool isAvailable;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    this.imagePath,
    required this.name,
    required this.price,
    required this.unit,
    this.isAvailable = true,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        width: AppConstants.cardWidth,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gambar produk ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusLG),
                    topRight: Radius.circular(AppConstants.radiusLG),
                  ),
                  child: imagePath != null
                  ? imagePath!.startsWith('http')
                      ? Image.network(
                          imagePath!,
                          width: double.infinity,
                          height: AppConstants.cardImageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : Image.asset(
                          imagePath!,
                          width: double.infinity,
                          height: AppConstants.cardImageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                  : _buildImagePlaceholder(),
                ),
                // Badge tidak tersedia
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConstants.radiusLG),
                          topRight: Radius.circular(AppConstants.radiusLG),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSM,
                          vertical: AppConstants.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        ),
                        child: Text(
                          'Habis',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Info produk ──
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    _formatPrice(price),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    '/ $unit',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppConstants.paddingSM),

                  // ── Tombol tambah keranjang ──
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: isAvailable ? onAddToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: AppColors.divider,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.add_rounded, size: AppConstants.iconMD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: AppConstants.cardImageHeight,
      color: AppColors.inputBackground,
      child: const Icon(
        Icons.eco_rounded,
        color: AppColors.primaryGreen,
        size: AppConstants.iconXL,
      ),
    );
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

// ─── Product Card Horizontal ──────────────────────────────────────────────────
/// Versi horizontal ProductCard untuk tampilan list / keranjang belanja.
///
/// Contoh:
/// ```dart
/// ProductCardHorizontal(
///   imagePath: 'assets/images/wortel.jpg',
///   name: 'Wortel Segar',
///   price: 8000,
///   unit: 'kg',
///   quantity: 2,
///   onTap: () {},
/// )
/// ```
class ProductCardHorizontal extends StatelessWidget {
  final String? imagePath;
  final String name;
  final int price;
  final String unit;
  final int? quantity;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const ProductCardHorizontal({
    super.key,
    this.imagePath,
    required this.name,
    required this.price,
    required this.unit,
    this.quantity,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingSM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: AppConstants.paddingMD),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingXS),
                  Text(
                    '${_formatPrice(price)} / $unit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (quantity != null) ...[
                    const SizedBox(height: AppConstants.paddingXS),
                    Text(
                      'x$quantity',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            if (trailingWidget != null) trailingWidget!,
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.inputBackground,
      child: const Icon(
        Icons.eco_rounded,
        color: AppColors.primaryGreen,
        size: AppConstants.iconLG,
      ),
    );
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}