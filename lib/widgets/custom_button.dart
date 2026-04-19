import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../core/constants.dart';

// ─── Primary Button ───────────────────────────────────────────────────────────
/// Tombol utama hijau dengan teks putih.
/// Digunakan untuk aksi utama seperti Login, Daftar, Pesan, dll.
///
/// Contoh:
/// ```dart
/// AppPrimaryButton(
///   label: 'Masuk',
///   onPressed: () {},
/// )
/// ```
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.buttonPrimary),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: AppConstants.iconMD),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─── Secondary / Outlined Button ──────────────────────────────────────────────
/// Tombol outlined untuk aksi sekunder.
///
/// Contoh:
/// ```dart
/// AppOutlinedButton(
///   label: 'Batal',
///   onPressed: () {},
/// )
/// ```
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double? width;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          foregroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryGreen,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.buttonPrimary.copyWith(
                    color: AppColors.primaryGreen,
                  )),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: AppConstants.iconMD),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─── Text Button ──────────────────────────────────────────────────────────────
/// Tombol teks tanpa background, untuk aksi ringan.
///
/// Contoh:
/// ```dart
/// AppTextButton(
///   label: 'Lihat Semua',
///   onPressed: () {},
/// )
/// ```
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? style;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: style ?? AppTextStyles.link,
      ),
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────
/// Tombol login dengan Google.
///
/// Contoh:
/// ```dart
/// AppGoogleButton(onPressed: () {})
/// ```
class AppGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppGoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: AppConstants.buttonHeightSM,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          AppConstants.googleLogo,
          width: AppConstants.iconLG,
          height: AppConstants.iconLG,
        ),
        label: const Text('Google', style: AppTextStyles.buttonSecondary),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.inputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
          backgroundColor: AppColors.white,
        ),
      ),
    );
  }
}