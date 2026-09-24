import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_card.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/deal_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  /// 0 = active deals, 1 = add a deal.
  int _tab = 0;
  final _search = ''.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProductController>(tag: 'products')
        ? Get.find<ProductController>(tag: 'products')
        : Get.put(ProductController(), tag: 'products');

    final bool mobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deals', style: AdminText.display(26)),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.activeDeals.length} products currently on sale',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
              SizedBox(height: mobile ? 16 : 20),
              _StatsRow(controller: controller, mobile: mobile),
              const SizedBox(height: 18),
              _TabBar(
                current: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 14),
              AdminSearchField(
                hintText: _tab == 0
                    ? 'Search active deals…'
                    : 'Search products to put on sale…',
                onChanged: (v) => _search.value = v,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final term = _search.value.trim().toLowerCase();
                  final source = _tab == 0
                      ? controller.activeDeals
                      : controller.dealCandidates;

                  final list = term.isEmpty
                      ? source
                      : source
                            .where((p) => p.name.toLowerCase().contains(term))
                            .toList();

                  if (list.isEmpty) {
                    return _EmptyState(isActiveTab: _tab == 0);
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
                        if (!mobile && _tab == 0) const _ActiveTableHeader(),
                        Expanded(
                          child: ListView.builder(
                            padding: mobile
                                ? const EdgeInsets.all(0)
                                : EdgeInsets.zero,
                            itemCount: list.length,
                            itemBuilder: (context, i) => _tab == 0
                                ? ActiveDealRow(
                                    product: list[i],
                                    controller: controller,
                                  )
                                : DealCandidateRow(
                                    product: list[i],
                                    controller: controller,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller, required this.mobile});

  final ProductController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final deals = controller.activeDeals;
      final avgDiscount = deals.isEmpty
          ? 0.0
          : deals.map((p) => p.discountPercentage).reduce((a, b) => a + b) /
                deals.length;
      final biggest = deals.isEmpty
          ? 0.0
          : deals
                .map((p) => p.discountPercentage)
                .reduce((a, b) => a > b ? a : b);

      final cards = [
        AdminStatCard(
          label: 'Active deals',
          value: '${deals.length}',
          icon: Icons.local_offer_outlined,
        ),
        AdminStatCard(
          label: 'Average discount',
          value: '${avgDiscount.toStringAsFixed(0)}%',
          icon: Icons.percent_rounded,
        ),
        AdminStatCard(
          label: 'Biggest discount',
          value: '${biggest.toStringAsFixed(0)}%',
          icon: Icons.trending_down_rounded,
          accent: AdminColors.success,
        ),
        AdminStatCard(
          label: 'Eligible products',
          value: '${controller.dealCandidates.length}',
          icon: Icons.inventory_2_outlined,
        ),
      ];

      if (mobile) {
        return Wrap(spacing: 10, runSpacing: 10, children: cards);
      }

      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      );
    });
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Active deals', 'Add a deal'];

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: current == i ? AdminColors.ink : AdminColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: current == i ? AdminColors.ink : AdminColors.line,
                ),
              ),
              child: Text(
                labels[i],
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: current == i ? Colors.white : AdminColors.inkSoft,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActiveTableHeader extends StatelessWidget {
  const _ActiveTableHeader();

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
          Expanded(flex: 4, child: Text('PRODUCT', style: style())),
          Expanded(flex: 2, child: Text('PRICE', style: style())),
          Expanded(flex: 2, child: Text('DISCOUNT', style: style())),
          const SizedBox(width: 78, child: Text('')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isActiveTab});

  final bool isActiveTab;

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
          Icon(
            isActiveTab
                ? Icons.local_offer_outlined
                : Icons.check_circle_outline_rounded,
            size: 34,
            color: const Color(0xFFC7C2D6),
          ),
          const SizedBox(height: 10),
          Text(
            isActiveTab ? 'No active deals' : 'No products match',
            style: AdminText.body(14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            isActiveTab
                ? 'Switch to "Add a deal" to put a product on sale.'
                : 'Try a different search — or every product is already on sale.',
            style: AdminText.body(13, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}
