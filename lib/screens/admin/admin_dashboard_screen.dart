import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../utils/app_theme.dart';
import 'categories_screen.dart';
import 'payment_methods_screen.dart';
import 'users_screen.dart';
import 'admin_transactions_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final AdminController adminController = Get.put(AdminController());
  final CategoryController categoryController = Get.put(CategoryController());
  final PaymentController paymentController = Get.put(PaymentController());

  AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminController.fetchDashboardStats();
      categoryController.fetchCategories();
      paymentController.fetchPaymentMethods();
      adminController.fetchUsers();
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.royalBlueDark,
                AppTheme.usafaBlue,
                AppTheme.darkCornflowerBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalBlueDark.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.white.withOpacity(0.25),
                                    AppTheme.white.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.white.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.dashboard_customize_rounded,
                                color: AppTheme.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard Admin',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'Manajemen Kantin Jawara',
                                    style: TextStyle(
                                      color: AppTheme.white.withOpacity(0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'logout') {
                              authController.logout();
                            }
                          },
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: AppTheme.white,
                            size: 26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            maxWidth: 200,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxWidth: 180,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        color: AppTheme.red,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Keluar',
                                        style: TextStyle(
                                          color: AppTheme.darkGray,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.royalBlueDark.withOpacity(0.05),
                AppTheme.lightGray.withOpacity(0.3),
                AppTheme.white,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                adminController.fetchDashboardStats(),
                categoryController.fetchCategories(),
                paymentController.fetchPaymentMethods(),
                adminController.fetchUsers(),
              ]);
            },
            color: AppTheme.royalBlueDark,
            backgroundColor: AppTheme.white,
            strokeWidth: 3.0,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      if (adminController.isLoading) {
                        return Container(
                          height: 180,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.white,
                                AppTheme.royalBlueDark.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.royalBlueDark.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.royalBlueDark.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.royalBlueDark,
                                    ),
                                    strokeWidth: 4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Memuat Statistik Dashboard',
                                  style: TextStyle(
                                    color: AppTheme.darkGray,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Harap tunggu sementara kami mengambil data terbaru...',
                                  style: TextStyle(
                                    color: AppTheme.mediumGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final stats = adminController.dashboardStats;
                      if (stats.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.white,
                                AppTheme.royalBlueDark.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.royalBlueDark.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.royalBlueDark,
                                          AppTheme.usafaBlue,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.royalBlueDark
                                              .withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.dashboard_rounded,
                                      color: AppTheme.white,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ringkasan Sistem',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkGray,
                                        ),
                                      ),
                                      Text(
                                        'Statistik real-time',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.mediumGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 400) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: _buildQuickStat(
                                            'Pengguna',
                                            stats['total_users']?.toString() ??
                                                '0',
                                            Icons.people,
                                            AppTheme.royalBlueDark,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildQuickStat(
                                            'Pesanan',
                                            stats['total_transactions']
                                                    ?.toString() ??
                                                '0',
                                            Icons.receipt_long,
                                            AppTheme.goldenPoppy,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildQuickStat(
                                            'Pendapatan',
                                            'Rp ${stats['total_revenue']?.toString() ?? '0'}',
                                            Icons.monetization_on,
                                            AppTheme.usafaBlue,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        _buildQuickStat(
                                          'Pengguna',
                                          stats['total_users']?.toString() ??
                                              '0',
                                          Icons.people,
                                          AppTheme.royalBlueDark,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildQuickStat(
                                          'Pesanan',
                                          stats['total_transactions']
                                                  ?.toString() ??
                                              '0',
                                          Icons.receipt_long,
                                          AppTheme.goldenPoppy,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildQuickStat(
                                          'Pendapatan',
                                          'Rp ${stats['total_revenue']?.toString() ?? '0'}',
                                          Icons.monetization_on,
                                          AppTheme.usafaBlue,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 24),

                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.goldenPoppy,
                                  AppTheme.goldenPoppy.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.goldenPoppy.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.flash_on_rounded,
                              color: AppTheme.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aksi Cepat',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkGray,
                                  ),
                                ),
                                Text(
                                  'Kelola sistem kantin dengan efisien',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.mediumGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        double childAspectRatio = constraints.maxWidth > 600
                            ? 1.0
                            : 0.85;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                          children: [
                            _buildDashboardCard(
                              icon: Icons.category_rounded,
                              title: 'Kategori',
                              subtitle: 'Kelola kategori makanan',
                              color: AppTheme.royalBlueDark,
                              onTap: () => Get.to(() => CategoriesScreen()),
                            ),
                            _buildDashboardCard(
                              icon: Icons.payment_rounded,
                              title: 'Metode Pembayaran',
                              subtitle: 'Kelola opsi pembayaran',
                              color: AppTheme.usafaBlue,
                              onTap: () => Get.to(() => PaymentMethodsScreen()),
                            ),
                            _buildDashboardCard(
                              icon: Icons.people_rounded,
                              title: 'Pengguna',
                              subtitle: 'Kelola pengguna & penjual',
                              color: AppTheme.goldenPoppy,
                              onTap: () => Get.to(() => const UsersScreen()),
                            ),
                            _buildDashboardCard(
                              icon: Icons.receipt_long_rounded,
                              title: 'Transaksi',
                              subtitle: 'Lihat semua transaksi',
                              color: AppTheme.darkCornflowerBlue,
                              onTap: () =>
                                  Get.to(() => AdminTransactionsScreen()),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.white),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [AppTheme.white, color.withOpacity(0.02)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Kurangi padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Tambahkan ini
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16), // Kurangi padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          spreadRadius: 0,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      child: Icon(icon, size: 32, color: AppTheme.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Kurangi spacing
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16, // Kurangi font size
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12, // Kurangi font size
                            color: AppTheme.mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
