import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../core/constants.dart';

// ─── Loading Indicator ────────────────────────────────────────────────────────
/// Spinner loading standar aplikasi SayurKu.
/// Bisa dipakai inline di dalam widget tree.
///
/// Contoh:
/// ```dart
/// // Tampilkan langsung di tengah layar
/// const AppLoadingIndicator()
///
/// // Dengan pesan
/// const AppLoadingIndicator(message: 'Memuat produk...')
///
/// // Ukuran kecil untuk inline
/// const AppLoadingIndicator(size: 20, strokeWidth: 2)
/// ```
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 36,
    this.strokeWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primaryGreen,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppConstants.paddingMD),
          Text(
            message!,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ─── Full Screen Loading Overlay ──────────────────────────────────────────────
/// Overlay loading yang menutupi seluruh layar.
/// Cocok dipakai saat proses login, submit form, dll.
///
/// Contoh:
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     if (isLoading) const AppLoadingOverlay(),
///   ],
/// )
/// ```
class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXL,
            vertical: AppConstants.paddingLG,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          child: AppLoadingIndicator(message: message ?? 'Mohon tunggu...'),
        ),
      ),
    );
  }
}

// ─── Shimmer Loading Card ─────────────────────────────────────────────────────
/// Placeholder shimmer untuk ProductCard saat data sedang dimuat.
/// Letakkan di GridView/ListView sambil menunggu data dari Firebase.
///
/// Contoh:
/// ```dart
/// GridView.builder(
///   itemBuilder: (context, index) {
///     return isLoading
///       ? const ShimmerProductCard()
///       : ProductCard(...);
///   },
/// )
/// ```
class ShimmerProductCard extends StatefulWidget {
  const ShimmerProductCard({super.key});

  @override
  State<ShimmerProductCard> createState() => _ShimmerProductCardState();
}

class _ShimmerProductCardState extends State<ShimmerProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: AppConstants.cardWidth,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar placeholder
              _ShimmerBox(
                width: double.infinity,
                height: AppConstants.cardImageHeight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusLG),
                  topRight: Radius.circular(AppConstants.radiusLG),
                ),
                opacity: _animation.value,
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      width: 100,
                      height: 12,
                      opacity: _animation.value,
                    ),
                    const SizedBox(height: AppConstants.paddingXS),
                    _ShimmerBox(
                      width: 70,
                      height: 12,
                      opacity: _animation.value,
                    ),
                    const SizedBox(height: AppConstants.paddingSM),
                    _ShimmerBox(
                      width: double.infinity,
                      height: 34,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSM,
                      ),
                      opacity: _animation.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double opacity;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputBackground.withValues(
          alpha: (opacity + 0.3).clamp(0.0, 1.0),
        ),
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusXS),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
/// Widget empty state untuk halaman tanpa data.
///
/// Contoh:
/// ```dart
/// AppEmptyState(
///   icon: Icons.shopping_cart_outlined,
///   title: 'Keranjang Kosong',
///   subtitle: 'Yuk tambahkan produk ke keranjangmu!',
///   actionLabel: 'Belanja Sekarang',
///   onAction: () {},
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconXL,
                color: AppColors.primaryGreen.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppConstants.paddingLG),
              SizedBox(
                width: 180,
                height: AppConstants.buttonHeightSM,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Text(actionLabel!, style: AppTextStyles.buttonPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
