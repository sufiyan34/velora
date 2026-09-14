import 'package:e_commerce/views/admin/categories_screen.dart';
import 'package:e_commerce/views/admin/products_screen.dart';
import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

/// Quick way to preview both screens together without wiring GetX routes
/// into the rest of the app yet. Swap this out once Products/Categories
/// are added to your real navigation (see README_ADMIN_SCREENS.md).
class AdminShellDemo extends StatefulWidget {
  const AdminShellDemo({super.key});

  @override
  State<AdminShellDemo> createState() => _AdminShellDemoState();
}

class _AdminShellDemoState extends State<AdminShellDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [ProductsScreen(), CategoriesScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AdminColors.surface,
        indicatorColor: AdminColors.brassTint,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}
