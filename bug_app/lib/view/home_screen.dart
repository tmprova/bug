import 'package:bug_app/providers/auth_provider.dart';
import 'package:bug_app/view/seller_screen.dart';
import 'package:bug_app/view/my_cart_screen.dart';
import 'package:bug_app/view/profile_screen.dart';
import 'package:bug_app/view/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _pageIndex = 0;

  // String userRole = 'user';// 'user' or 'seller'

  // Function to navigate based on the user's role
  // void _selectScreen(int index) {
  // if (userRole == 'user' && index == 1) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('You do not have access to this screen')),
  //   );
  //   return;
  // }

  // if (userRole == 'buyer' && index == 0) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('You do not have access to this screen')),
  //   );
  //   return;
  // }

  // Use routes from routes.dart to navigate
  //   switch (index) {
  //     case 0:
  //       Navigator.pushNamed(context, Routes.report);
  //       break;
  //     case 1:
  //       Navigator.pushNamed(context, Routes.responder);
  //       break;
  //     case 2:
  //       Navigator.pushNamed(context, Routes.profile);
  //       break;
  //     default:
  //       Navigator.pushNamed(context, Routes.home);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Read the user role from Riverpod
    final user =
        ref.read(authProvider); // Assuming authProvider holds user data

    // if (user == null) {
    //   //   // If the user data is null, show a loading spinner or navigate to login screen
    //   return const Center(child: CircularProgressIndicator());
    // }
    final isSeller = user?.role == 'seller';
    final List<Widget> pages = [
      const ShopScreen(),
      const MyCartScreen(),
      SellerScreen(),
      ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.shop_outlined, color: Color(0xFF2E7D32)),
        label: "Shop",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.card_travel, color: Color(0xFF2E7D32)),
        label: "My Cart",
      ),

      // const BottomNavigationBarItem(
      //   icon: Icon(Icons.person_3, color: Color(0xFF2E7D32)),
      //   label: "Seller",
      // ),
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

    // Prevent invalid index when responder section is hidden
    if (!isSeller && _pageIndex == 2) {
      _pageIndex = 0; // Redirect to first tab if needed
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2E7D32), // Deep eco green
        unselectedItemColor: const Color(0xFF81C784), // Soft green
        backgroundColor: const Color(0xFFEDF7ED), // Light eco background
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,

        items: navItems,
      ),
      body: pages[_pageIndex],
    );
  }
}
