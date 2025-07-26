import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/penjual_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../utils/app_theme.dart';
import 'seller_orders_screen.dart';
import 'manage_menus_screen.dart';
import 'merchant_payment_list_screen.dart';
import '../shared/profile_screen.dart';

class PenjualDashboardScreen extends StatefulWidget {
  const PenjualDashboardScreen({super.key});

  @override
  State<PenjualDashboardScreen> createState() => _PenjualDashboardScreenState();
}

class _PenjualDashboardScreenState extends State<PenjualDashboardScreen> {
  int _currentIndex = 0;
  final AuthController authController = Get.find<AuthController>();
  final PenjualController penjualController = Get.put(PenjualController());
  final ChatController chatController = Get.put(ChatController());
  final menu_ctrl.MenuController menuController = Get.put(
    menu_ctrl.MenuController(),
  );

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      SellerDashboardHome(onViewAllOrders: () => _switchToOrdersTab()),
      const SellerOrdersScreen(),
      const ManageMenusScreen(),
      const ProfileScreen(),
    ]);
  }

  void _switchToOrdersTab() {
    setState(() {
      _currentIndex = 1;
    });
    penjualController.fetchTransactions();
    chatController.fetchChatList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.mediumGray.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });

              if (index == 2) {
                // print('PenjualDashboard: Menus tab selected, fetching data...');
                menuController.fetchMyMenus();
              } else if (index == 1) {
                // print(
                // 'PenjualDashboard: Orders tab selected, fetching data...',
                // );
                penjualController.fetchTransactions();
                chatController.fetchChatList();
              } else if (index == 0) {
                // print(
                // 'PenjualDashboard: Dashboard tab selected, fetching data...',
                // );
                penjualController.fetchTransactions();
              } else if (index == 3) {
                // print(
                // 'PenjualDashboard: Profile tab selected, fetching profile...',
                // );
                authController.fetchProfile();
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.white,
            selectedItemColor: AppTheme.royalBlueDark,
            unselectedItemColor: AppTheme.mediumGray,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 0
                      ? BoxDecoration(
                          color: AppTheme.royalBlueDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    Icons.dashboard,
                    color: _currentIndex == 0
                        ? AppTheme.royalBlueDark
                        : AppTheme.mediumGray,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 1
                      ? BoxDecoration(
                          color: AppTheme.royalBlueDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Badge(
                    isLabelVisible: penjualController
                        .getPendingTransactions()
                        .isNotEmpty,
                    label: Text(
                      penjualController
                          .getPendingTransactions()
                          .length
                          .toString(),
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.red,
                    child: Icon(
                      Icons.shopping_bag,
                      color: _currentIndex == 1
                          ? AppTheme.royalBlueDark
                          : AppTheme.mediumGray,
                    ),
                  ),
                ),
                label: 'Transaksi',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 2
                      ? BoxDecoration(
                          color: AppTheme.royalBlueDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    Icons.restaurant_menu,
                    color: _currentIndex == 2
                        ? AppTheme.royalBlueDark
                        : AppTheme.mediumGray,
                  ),
                ),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: _currentIndex == 3
                      ? BoxDecoration(
                          color: AppTheme.royalBlueDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    Icons.person,
                    color: _currentIndex == 3
                        ? AppTheme.royalBlueDark
                        : AppTheme.mediumGray,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellerDashboardHome extends StatelessWidget {
  final VoidCallback? onViewAllOrders;

  const SellerDashboardHome({super.key, this.onViewAllOrders});

  @override
  Widget build(BuildContext context) {
    final PenjualController controller = Get.find<PenjualController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.royalBlueDark, AppTheme.usafaBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalBlueDark.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Penjual',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          Text(
                            'Kelola toko Anda secara efisien',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: AppTheme.white,
                          size: 28,
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
      body: RefreshIndicator(
        color: AppTheme.royalBlueDark,
        onRefresh: () => controller.fetchTransactions(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.lightGray, AppTheme.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaksi Hari Ini',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => controller.isLoading
                      ? Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppTheme.royalBlueDark,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Memuat data transaksi...',
                                  style: TextStyle(
                                    color: AppTheme.mediumGray,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                          children: [
                            _buildStatCard(
                              title: 'Total Penjualan',
                              value:
                                  'Rp ${controller.getTodaysSales().toStringAsFixed(0)}',
                              icon: Icons.monetization_on,
                              color: AppTheme.goldenPoppy,
                            ),
                            _buildStatCard(
                              title: 'Pesanan Hari Ini',
                              value: controller
                                  .getTodaysTransactions()
                                  .length
                                  .toString(),
                              icon: Icons.shopping_bag,
                              color: AppTheme.royalBlueDark,
                            ),
                            _buildStatCard(
                              title: 'Pesanan Tertunda',
                              value: controller
                                  .getPendingTransactions()
                                  .length
                                  .toString(),
                              icon: Icons.pending,
                              color: AppTheme.goldenPoppy,
                            ),
                            _buildStatCard(
                              title: 'Selesai',
                              value: controller
                                  .getCompletedTransactions()
                                  .length
                                  .toString(),
                              icon: Icons.check_circle,
                              color: AppTheme.usafaBlue,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Tindakan Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () =>
                              Get.to(() => const MerchantPaymentListScreen()),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.royalBlueDark.withOpacity(0.05),
                                  AppTheme.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.royalBlueDark,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.payment_rounded,
                                      size: 24,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Metode\nPembayaran',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.darkGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.goldenPoppy.withOpacity(0.05),
                                  AppTheme.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.usafaBlue.withOpacity(0.05),
                                  AppTheme.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pesanan Terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (onViewAllOrders != null) {
                          onViewAllOrders!();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.royalBlueDark,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoading) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.royalBlueDark,
                                strokeWidth: 2,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Memuat pesanan terbaru...',
                                style: TextStyle(
                                  color: AppTheme.mediumGray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final recentOrders = controller.transactions.take(5).toList();

                  if (recentOrders.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 48,
                                color: AppTheme.mediumGray,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada pesanan',
                                style: TextStyle(color: AppTheme.mediumGray),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: recentOrders
                        .map((order) => _buildOrderCard(order))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), AppTheme.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.white, AppTheme.lightGray.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.royalBlueDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: AppTheme.royalBlueDark,
              size: 24,
            ),
          ),
          title: Text(
            'Order #${order.id ?? 'N/A'}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          subtitle: Text(
            'Rp ${order.totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              color: AppTheme.royalBlueDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.goldenPoppy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.goldenPoppy.withOpacity(0.3)),
            ),
            child: Text(
              order.status.toString().split('.').last,
              style: const TextStyle(
                color: AppTheme.goldenPoppy,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
