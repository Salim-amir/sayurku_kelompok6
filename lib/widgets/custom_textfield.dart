import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/colors.dart';
import '../core/text_styles.dart';
import '../core/constants.dart';

// ─── App Text Field ───────────────────────────────────────────────────────────
/// TextField serbaguna untuk seluruh aplikasi SayurKu.
/// Mendukung berbagai tipe: teks biasa, password, nomor HP, angka.
///
/// Contoh penggunaan:
/// ```dart
/// AppTextField(
///   label: 'NOMOR HP',
///   hintText: '08xx xxxx xxxx',
///   prefixIcon: Icons.phone_android_rounded,
///   keyboardType: TextInputType.phone,
///   controller: _phoneController,
/// )
/// ```
class AppTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSuffixTap;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AppTextField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixWidget,
    this.errorText,
    this.onChanged,
    this.onSuffixTap,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.labelUppercase),
          const SizedBox(height: AppConstants.paddingSM),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.inputHint,
            errorText: errorText,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textHint, size: AppConstants.iconMD)
                : null,
            suffixIcon: suffixWidget != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: suffixWidget,
                  )
                : null,
            filled: true,
            fillColor: enabled ? AppColors.inputBackground : AppColors.divider,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingMD,
              horizontal: AppConstants.paddingMD,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Password Text Field ──────────────────────────────────────────────────────
/// TextField khusus password dengan toggle show/hide bawaan.
///
/// Contoh:
/// ```dart
/// AppPasswordField(
///   label: 'KATA SANDI',
///   hintText: '••••••••',
///   controller: _passwordController,
/// )
/// ```
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? trailingAction;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AppPasswordField({
    super.key,
    this.label,
    required this.hintText,
    this.controller,
    this.errorText,
    this.onChanged,
    this.trailingAction,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.trailingAction != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(widget.label!, style: AppTextStyles.labelUppercase),
              if (widget.trailingAction != null) widget.trailingAction!,
            ],
          ),
        if (widget.label != null || widget.trailingAction != null)
          const SizedBox(height: AppConstants.paddingSM),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 18),
            errorText: widget.errorText,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textHint,
              size: AppConstants.iconMD,
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: AppConstants.iconMD,
              ),
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.paddingMD,
              horizontal: AppConstants.paddingMD,
            ),
          ),
        ),
      ],
    );
  }
}