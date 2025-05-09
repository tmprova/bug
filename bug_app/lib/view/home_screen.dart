import 'package:bug_app/providers/auth_provider.dart';
import 'package:bug_app/view/seller_screen.dart';
import 'package:bug_app/view/my_cart_screen.dart';
import 'package:bug_app/view/profile_screen.dart';
import 'package:bug_app/view/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final user = ref.watch(authProvider);

    // 🕒 Show loading spinner while user data is being restored
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isSeller = user?.role == 'seller';

    // Dynamically configure navigation items and page list
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.shop_outlined, color: Color(0xFF2E7D32)),
        label: "Shop",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.card_travel, color: Color(0xFF2E7D32)),
        label: "My Cart",
      ),
      if (isSeller)
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_3, color: Color(0xFF2E7D32)),
          label: "Seller",
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Color(0xFF2E7D32)),
        label: "Profile",
      ),
    ];

    final pages = <Widget>[
      const ShopScreen(),
      const MyCartScreen(),
      if (isSeller) SellerScreen(),
      ProfileScreen(),
    ];

    // Prevent index out-of-bounds
    if (_pageIndex >= pages.length) {
      _pageIndex = 0;
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2E7D32), // Deep eco green
        unselectedItemColor: const Color(0xFF81C784), // Soft green
        backgroundColor: const Color(0xFFEDF7ED), // Light eco background
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
      body: pages[_pageIndex],
    );
  }
}
