import 'package:e_commerce/constants/app_colors.dart';
import 'package:e_commerce/controllers/velora_sidebar_controller.dart';
import 'package:e_commerce/utills/velora_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reference wiring for the Velora admin panel.
/// Swap `Icons.*` for `Iconsax.*` if you prefer — any IconData works.
class VeloraAdminShell extends StatelessWidget {
  final Widget child;
  final String pageTitle;

  const VeloraAdminShell({
    super.key,
    required this.child,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = VeloraSidebarController.instance;

    return VeloraNavShell(
      title: pageTitle,
      child: child,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: VeloraColors.ink700,
        ),
      ],
      footerBuilder: (context, expanded) => VeloraSidebarProfile(
        expanded: expanded,
        name: 'Sufyan',
        role: 'Administrator',
        onTap: () => Get.toNamed('/settings/profile'),
      ),
      items: [
        VeloraSidebarItem(
          icon: Icons.grid_view_rounded,
          label: 'Dashboard',
          section: 'Overview',
          isActive: true,
          onTap: () => Get.toNamed('/dashboard'),
        ),
        VeloraSidebarItem(
          icon: Icons.insights_rounded,
          label: 'Reports',
          section: 'Overview',
          onTap: () => Get.toNamed('/reports'),
        ),
        VeloraSidebarItem(
          icon: Icons.receipt_long_rounded,
          label: 'Orders',
          badge: '12',
          badgeColor: VeloraColors.amber,
          section: 'Commerce',
          onTap: () => Get.toNamed('/orders'),
        ),
        VeloraSidebarItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Products',
          section: 'Commerce',
          onTap: () => Get.toNamed('/products'),
        ),
        VeloraSidebarItem(
          icon: Icons.category_outlined,
          label: 'Categories',
          section: 'Commerce',
          onTap: () => Get.toNamed('/categories'),
        ),
        VeloraSidebarItem(
          icon: Icons.local_shipping_outlined,
          label: 'Dispatch',
          section: 'Commerce',
          onTap: () => Get.toNamed('/dispatch'),
        ),
        VeloraSidebarItem(
          icon: Icons.people_alt_outlined,
          label: 'Customers',
          section: 'People',
          onTap: () => Get.toNamed('/customers'),
        ),
        VeloraSidebarItem(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Support chat',
          badge: '3',
          badgeColor: VeloraColors.emerald,
          section: 'People',
          onTap: () => Get.toNamed('/chat'),
        ),
        VeloraSidebarItem(
          icon: Icons.auto_awesome_outlined,
          label: 'AI assistant',
          section: 'People',
          onTap: () => Get.toNamed('/ai-assistant'),
        ),
        VeloraSidebarItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          section: 'System',
          onTap: () {
            c.syncSelection(9); // keeps the highlight if routed elsewhere
            Get.toNamed('/settings');
          },
        ),
      ],
    );
  }
}
