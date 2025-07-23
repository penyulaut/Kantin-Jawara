import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pembeli_controller.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../controllers/chat_controller.dart';
import '../../controllers/cart_controller.dart';
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
    // Initial fetch for menu and cart when dashboard opens
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
    // Refresh cart when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      print('PembeliDashboard: App resumed, refreshing cart...');
      if (authController.isLoggedIn) {
        cartController.refreshCart();
      }
    }
  }

  Future<void> _initializeData() async {
    // Wait for auth to be ready
    await Future.delayed(const Duration(milliseconds: 200));

    // Double check auth status
    if (authController.isLoggedIn && authController.currentUser != null) {
      print('PembeliDashboard: User authenticated, initializing data...');

      // Fetch menus first (no auth required)
      menuController.fetchMenus();

      // Then fetch cart (requires auth)
      print('PembeliDashboard: Fetching cart...');
      await cartController.fetchCart();
      print(
        'PembeliDashboard: Cart items count: ${cartController.cartItems.length}',
      );

      // Also fetch chat unread count
      try {
        chatController.fetchUnreadCount();
      } catch (e) {
        print('PembeliDashboard: Error fetching unread count: $e');
      }
    } else {
      print(
        'PembeliDashboard: User not authenticated, skipping data initialization',
      );
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
        () => BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Fetch data when specific tabs are selected
            if (index == 1) {
              // My Orders tab - fetch transactions
              pembeliController.fetchTransactions();
            } else if (index == 0) {
              // Menu tab - fetch menus and cart
              menuController.fetchMenus();
              cartController.fetchCart();
            } else if (index == 2) {
              // Chat tab - fetch chat list and unread count
              chatController.fetchChatList();
              chatController.fetchUnreadCount();
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: chatController.unreadCount > 0,
                label: Text(chatController.unreadCount.toString()),
                child: const Icon(Icons.chat),
              ),
              label: 'Chat',
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
