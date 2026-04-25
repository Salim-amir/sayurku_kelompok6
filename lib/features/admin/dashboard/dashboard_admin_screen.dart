import 'package:flutter/material.dart';
import 'package:sayurku_kelompok6/core/colors.dart';
import 'package:sayurku_kelompok6/core/text_styles.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      // ─── BODY ───────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Section Title
            Text(
              'Ringkasan Penjualan',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 4),
            Text(
              'Laporan performa toko minggu ini',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // ─ Revenue Card with Chart
            _buildRevenueCard(),
            const SizedBox(height: 24),

            // ─ Stats Cards
            Row(
              children: [
                Expanded(child: _buildStatCard(
                  icon: Icons.check_circle,
                  iconColor: AppColors.success,
                  number: '124',
                  label: 'Pesanan Selesai',
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                  number: '5',
                  label: 'Stok Hampir Habis',
                )),
              ],
            ),
            const SizedBox(height: 24),

            // ─ Promo Card
            _buildPromoCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      // ─── BOTTOM NAVIGATION ──────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ─── REVENUE CARD ────────────────────────────────────────
  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PENDAPATAN MINGGUAN',
                    style: AppTextStyles.labelUppercase,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp 4.200.000',
                    style: AppTextStyles.h1,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+10.5%',
                  style: AppTextStyles.labelLink.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          _buildChart(),
        ],
      ),
    );
  }

  // ─── CHART BAR ──────────────────────────────────────────
  Widget _buildChart() {
    final chartData = [45, 65, 50, 60, 55, 70, 90];
    final maxHeight = 120.0;

    return SizedBox(
      height: maxHeight + 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          chartData.length,
          (index) {
            final height = (chartData[index] / 100) * maxHeight;
            final isLast = index == chartData.length - 1;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 28,
                  height: height,
                  decoration: BoxDecoration(
                    color: isLast
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── STAT CARD ───────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String number,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // ─── PROMO CARD ──────────────────────────────────────────
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimalkan Stok\nGudang Hari Ini',
                  style: AppTextStyles.h3.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sayur dalam kandungan memerlukan pemantauan stok sagi...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kelola Stok',
                    style: AppTextStyles.buttonPrimary.copyWith(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Placeholder untuk image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_outlined,
              color: AppColors.white.withOpacity(0.5),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
