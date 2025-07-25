import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pembeli_controller.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/chat_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';
import 'menu_list_screen.dart';
import 'my_orders_screen.dart';
import 'chat_list_screen.dart';
import '../shared/profile_screen.dart';

class PembeliDashboardScreen extends StatefulWidget {
  const PembeliDashboardScreen({super.key});

  @override
  State<PembeliDashboardScreen> createState() => _PembeliDashboardScreenState();
}

class _PembeliDashboardScreenState extends State<PembeliDashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final AuthController authController = Get.find<AuthController>();
  final PembeliController pembeliController = Get.put(PembeliController());
  final menu_ctrl.MenuController menuController = Get.put(
    menu_ctrl.MenuController(),
  );
  final ChatController chatController = Get.put(ChatController());
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (authController.isLoggedIn) {
        cartController.refreshCart();
      }
    }
  }

  Future<void> _initializeData() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (authController.isLoggedIn && authController.currentUser != null) {

      menuController.fetchMenus();

      await cartController.fetchCart();

      try {
        chatController.fetchUnreadCount();
      } catch (e) {
      }
    } else {
    }
  }

  final List<Widget> _screens = [
    const MenuListScreen(),
    const MyOrdersScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGray.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });

              if (index == 1) {
                pembeliController.fetchTransactions();
              } else if (index == 0) {
                menuController.fetchMenus();
                cartController.fetchCart();
              } else if (index == 2) {
                chatController.fetchChatList();
                chatController.fetchUnreadCount();
              } else if (index == 3) {
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
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: _currentIndex == 0 ? 26 : 24,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.royalBlueDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 26,
                    color: AppTheme.royalBlueDark,
                  ),
                ),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  child: Badge(
                    isLabelVisible: pembeliController.transactions
                        .where(
                          (t) =>
                              t.status == TransactionStatus.pending ||
                              t.status == TransactionStatus.paid ||
                              t.status == TransactionStatus.confirmed ||
                              t.status == TransactionStatus.ready,
                        )
                        .isNotEmpty,
                    label: Text(
                      pembeliController.transactions
                          .where(
                            (t) =>
                                t.status == TransactionStatus.pending ||
                                t.status == TransactionStatus.paid ||
                                t.status == TransactionStatus.confirmed ||
                                t.status == TransactionStatus.ready,
                          )
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
                      Icons.shopping_bag_outlined,
                      size: _currentIndex == 1 ? 26 : 24,
                    ),
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.royalBlueDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Badge(
                    isLabelVisible: pembeliController.transactions
                        .where(
                          (t) =>
                              t.status == TransactionStatus.pending ||
                              t.status == TransactionStatus.paid ||
                              t.status == TransactionStatus.confirmed ||
                              t.status == TransactionStatus.ready,
                        )
                        .isNotEmpty,
                    label: Text(
                      pembeliController.transactions
                          .where(
                            (t) =>
                                t.status == TransactionStatus.pending ||
                                t.status == TransactionStatus.paid ||
                                t.status == TransactionStatus.confirmed ||
                                t.status == TransactionStatus.ready,
                          )
                          .length
                          .toString(),
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.red,
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 26,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                label: 'Pesanan',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  child: Badge(
                    isLabelVisible: chatController.unreadCount > 0,
                    label: Text(
                      chatController.unreadCount.toString(),
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.red,
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: _currentIndex == 2 ? 26 : 24,
                    ),
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.royalBlueDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Badge(
                    isLabelVisible: chatController.unreadCount > 0,
                    label: Text(
                      chatController.unreadCount.toString(),
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.red,
                    child: const Icon(
                      Icons.chat_bubble,
                      size: 26,
                      color: AppTheme.royalBlueDark,
                    ),
                  ),
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.person_outline,
                    size: _currentIndex == 3 ? 26 : 24,
                  ),
                ),
                activeIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.royalBlueDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 26,
                    color: AppTheme.royalBlueDark,
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
