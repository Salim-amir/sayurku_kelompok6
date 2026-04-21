class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────
  static const String appName        = 'SayurKu';
  static const String appTagline     = 'Segar Langsung ke Rumah';
  static const String appVersion     = '1.0.0';

  // ─── Asset Paths ──────────────────────────────────────────────
  static const String heroImage      = 'assets/images/hero_vegetables.jpg';
  static const String googleLogo     = 'assets/images/google_logo.png';
  static const String logoIcon       = 'assets/images/logo.png';
  static const String emptyCart      = 'assets/images/empty_cart.png';
  static const String emptyOrder     = 'assets/images/empty_order.png';

  // ─── Padding & Spacing ────────────────────────────────────────
  static const double paddingXS      = 4.0;
  static const double paddingSM      = 8.0;
  static const double paddingMD      = 16.0;
  static const double paddingLG      = 24.0;
  static const double paddingXL      = 32.0;
  static const double paddingXXL     = 48.0;

  // ─── Border Radius ────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusSM       = 8.0;
  static const double radiusMD       = 12.0;
  static const double radiusLG       = 16.0;
  static const double radiusXL       = 24.0;
  static const double radiusFull     = 100.0;

  // ─── Icon Size ────────────────────────────────────────────────
  static const double iconSM         = 16.0;
  static const double iconMD         = 20.0;
  static const double iconLG         = 24.0;
  static const double iconXL         = 32.0;

  // ─── Button ───────────────────────────────────────────────────
  static const double buttonHeight   = 52.0;
  static const double buttonHeightSM = 44.0;

  // ─── Input Field ──────────────────────────────────────────────
  static const double inputHeight    = 52.0;

  // ─── Product Card ─────────────────────────────────────────────
  static const double cardWidth      = 160.0;
  static const double cardImageHeight = 110.0;

  // ─── Splash ───────────────────────────────────────────────────
  static const int splashDuration    = 3; // detik

  // ─── Satuan Produk ────────────────────────────────────────────
  static const List<String> satuanProduk = [
    'kg',
    'gram',
    'ikat',
    'buah',
    'pack',
    'liter',
  ];

  // ─── Status Pesanan ───────────────────────────────────────────
  static const String statusMenunggu        = 'Menunggu Konfirmasi';
  static const String statusDiproses        = 'Diproses';
  static const String statusDikirim         = 'Dikirim';
  static const String statusSelesai         = 'Selesai';
  static const String statusDibatalkan      = 'Dibatalkan';

  // ─── Metode Pembayaran ────────────────────────────────────────
  static const String metodeCOD             = 'COD';
  static const String metodeTransfer        = 'Transfer Bank';
  static const String metodeDompet          = 'Dompet Digital';

  // ─── Firebase Collection Names ────────────────────────────────
  static const String colUsers              = 'users';
  static const String colProducts           = 'products';
  static const String colOrders             = 'orders';
  static const String colWallets            = 'wallets';
  static const String colNotifications      = 'notifications';
  static const String colAddresses          = 'addresses';

  // ─── Firebase Subcollection Names ──────────────────────────────
  static const String subColTransactions    = 'transactions';
  static const String subColAddresses       = 'addresses';

  // ─── Shared Preferences Keys ──────────────────────────────────
  static const String prefIsLoggedIn        = 'is_logged_in';
  static const String prefUserId            = 'user_id';
  static const String prefUserRole          = 'user_role';

  // ─── User Role ────────────────────────────────────────────────
  static const String roleCustomer          = 'customer';
  static const String roleAdmin             = 'admin';

  // ─── Snackbar / Toast Messages ────────────────────────────────
  static const String msgLoginSuccess       = 'Berhasil masuk!';
  static const String msgLoginFailed        = 'Email atau kata sandi salah.';
  static const String msgRegisterSuccess    = 'Akun berhasil dibuat!';
  static const String msgLogoutSuccess      = 'Berhasil keluar.';
  static const String msgCartAdded          = 'Produk ditambahkan ke keranjang.';
  static const String msgOrderSuccess       = 'Pesanan berhasil dibuat!';
  static const String msgTopUpSuccess       = 'Saldo berhasil ditambahkan.';
  static const String msgNetworkError       = 'Gagal terhubung. Cek koneksi internet.';
  static const String msgUnknownError       = 'Terjadi kesalahan. Coba lagi.';

  // ─── Wallet Transaction Types ──────────────────────────────────
  static const String txTopUp               = 'topup';
  static const String txPayment             = 'payment';

  // ─── Wallet Transaction Status ─────────────────────────────────
  static const String txStatusPending       = 'pending';
  static const String txStatusApproved      = 'approved';
  static const String txStatusRejected      = 'rejected';
  static const String txStatusSuccess       = 'success';

  // ─── Nominal Top-Up Options ────────────────────────────────────
  static const List<int> topUpNominals = [
    50000,
    100000,
    200000,
    500000,
  ];
}