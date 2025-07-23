import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/penjual_controller.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/chat_controller.dart';
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
  final menu_ctrl.MenuController menuController = Get.put(
    menu_ctrl.MenuController(),
  );
  final ChatController chatController = Get.put(ChatController());

  final List<Widget> _screens = [
    const SellerDashboardHome(),
    const SellerOrdersScreen(),
    const ManageMenusScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Fetch data when specific tabs are selected
            if (index == 2) {
              // Menus tab - fetch menu data
              menuController.fetchMyMenus();
            } else if (index == 1) {
              // Orders tab - fetch transaction data
              penjualController.fetchTransactions();
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: penjualController
                    .getPendingTransactions()
                    .isNotEmpty,
                label: Text(
                  penjualController.getPendingTransactions().length.toString(),
                ),
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menus',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class SellerDashboardHome extends StatelessWidget {
  const SellerDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final PenjualController controller = Get.find<PenjualController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchTransactions(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              const Text(
                'Today\'s Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(
                () => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      title: 'Total Sales',
                      value:
                          'Rp ${controller.getTodaysSales().toStringAsFixed(0)}',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      title: 'Orders Today',
                      value: controller
                          .getTodaysTransactions()
                          .length
                          .toString(),
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      title: 'Pending Orders',
                      value: controller
                          .getPendingTransactions()
                          .length
                          .toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      title: 'Completed',
                      value: controller
                          .getCompletedTransactions()
                          .length
                          .toString(),
                      icon: Icons.check_circle,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () =>
                            Get.to(() => const MerchantPaymentListScreen()),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.payment,
                                size: 32,
                                color: Colors.green,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Payment\nMethods',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Container()), // Placeholder for more actions
                  const SizedBox(width: 12),
                  Expanded(child: Container()), // Placeholder for more actions
                ],
              ),
              const SizedBox(height: 24),

              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Switch to orders tab
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
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
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No orders yet',
                              style: TextStyle(color: Colors.grey),
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
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.shopping_bag, color: Colors.green[700]),
        ),
        title: Text('Order #${order.id}'),
        subtitle: Text('Rp ${order.totalPrice.toStringAsFixed(0)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange),
          ),
          child: Text(
            order.status.toString().split('.').last,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
