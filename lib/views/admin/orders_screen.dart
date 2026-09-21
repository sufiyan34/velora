import 'package:e_commerce/controllers/admin_orders_controller.dart';
import 'package:e_commerce/models/order_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/admin_skeleton.dart';
import 'package:e_commerce/utills/order_status_style.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/order_detail_drawer.dart';
import 'package:e_commerce/views/admin/order_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminOrdersController>()
        ? Get.find<AdminOrdersController>()
        : Get.put(AdminOrdersController(), permanent: true);

    final bool mobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(controller: controller),
              const SizedBox(height: 16),
              _StatusTabs(controller: controller),
              const SizedBox(height: 14),
              AdminSearchField(
                hintText: 'Search by order ID, customer or product…',
                onChanged: (v) => controller.searchTerm.value = v,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return mobile
                        ? ListView.builder(
                            itemCount: 5,
                            itemBuilder: (_, __) => const AdminCardSkeleton(),
                          )
                        : const AdminListSkeleton(trailingColumns: 3);
                  }

                  final list = controller.filtered;
                  if (list.isEmpty) return const _EmptyState();

                  if (mobile) {
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) => _AnimatedRow(
                        index: i,
                        child: OrderRow(
                          order: list[i],
                          customerName: list[i].shippingAddress.fullName.isEmpty
                              ? 'Guest'
                              : list[i].shippingAddress.fullName,
                          busy: controller.busyOrderId.value == list[i].id,
                          onTap: () => showOrderDetailDrawer(
                            context: context,
                            orderId: list[i].id,
                            controller: controller,
                          ),
                          onAccept: () => controller.acceptOrder(list[i].id),
                          onReject: () => controller.rejectOrder(list[i].id),
                        ),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        const _TableHeader(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, i) => _AnimatedRow(
                              index: i,
                              child: OrderRow(
                                order: list[i],
                                customerName:
                                    list[i].shippingAddress.fullName.isEmpty
                                    ? 'Guest'
                                    : list[i].shippingAddress.fullName,
                                busy:
                                    controller.busyOrderId.value == list[i].id,
                                onTap: () => showOrderDetailDrawer(
                                  context: context,
                                  orderId: list[i].id,
                                  controller: controller,
                                ),
                                onAccept: () =>
                                    controller.acceptOrder(list[i].id),
                                onReject: () =>
                                    controller.rejectOrder(list[i].id),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedRow extends StatelessWidget {
  const _AnimatedRow({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: 22 * (index.clamp(0, 12))))
        .fadeIn(duration: const Duration(milliseconds: 240))
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final AdminOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Orders', style: AdminText.display(26)),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.orders.length} total orders',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.controller});

  final AdminOrdersController controller;

  static const _tabs = <String>['all', ...OrderStatuses.all];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(() {
        final counts = controller.counts;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final status = _tabs[i];
            final bool active = controller.statusFilter.value == status;
            final String label = status == 'all'
                ? 'All'
                : OrderStatusStyle.label(status);
            final int count = counts[status] ?? 0;

            return GestureDetector(
              onTap: () => controller.statusFilter.value = status,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AdminColors.ink : AdminColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AdminColors.ink : AdminColors.line,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AdminText.body(
                        12.5,
                        weight: FontWeight.w600,
                        color: active ? Colors.white : AdminColors.inkSoft,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: 0.18)
                              : AdminColors.canvas,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count',
                          style: AdminText.body(
                            11,
                            weight: FontWeight.w600,
                            color: active ? Colors.white : AdminColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    TextStyle style() =>
        AdminText.body(11.5, weight: FontWeight.w600, color: AdminColors.muted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('ORDER', style: style())),
          Expanded(flex: 2, child: Text('ITEMS', style: style())),
          Expanded(flex: 2, child: Text('TOTAL', style: style())),
          Expanded(flex: 2, child: Text('PAYMENT', style: style())),
          Expanded(flex: 2, child: Text('STATUS', style: style())),
          Expanded(flex: 2, child: Text('PLACED', style: style())),
          const SizedBox(width: 78, child: Text('')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.line),
      ),
      padding: const EdgeInsets.symmetric(vertical: 52),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 34,
            color: Color(0xFFC7C2D6),
          ),
          const SizedBox(height: 10),
          Text(
            'No orders found',
            style: AdminText.body(14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Try a different search or status filter.',
            style: AdminText.body(13, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}
