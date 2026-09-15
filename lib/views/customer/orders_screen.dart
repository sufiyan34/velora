import 'package:e_commerce/controllers/auth_controller.dart';
import 'package:e_commerce/controllers/order_controller.dart';
import 'package:e_commerce/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrderController orderController;
  late final AuthController authController;

  String selectedFilter = 'All';

  final List<String> filters = const [
    'All',
    'Pending',
    'Processing',
    'Dispatched',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();

    orderController = Get.find<OrderController>();
    authController = Get.find<AuthController>();

    _listenToOrders();
  }

  void _listenToOrders() {
    final userId = authController.userId;

    if (userId.isEmpty) {
      return;
    }

    orderController.listenToUserOrders(userId);
  }

  List<OrderModel> get filteredOrders {
    final orders = orderController.orders.toList();

    switch (selectedFilter) {
      case 'Pending':
        return orders
            .where((order) => order.orderStatus.toLowerCase() == 'pending')
            .toList();

      case 'Processing':
        return orders
            .where(
              (order) =>
                  order.orderStatus.toLowerCase() == 'processing' ||
                  order.orderStatus.toLowerCase() == 'accepted',
            )
            .toList();

      case 'Dispatched':
        return orders
            .where(
              (order) =>
                  order.orderStatus.toLowerCase() == 'dispatched' ||
                  order.orderStatus.toLowerCase() == 'out_for_delivery',
            )
            .toList();

      case 'Delivered':
        return orders
            .where((order) => order.orderStatus.toLowerCase() == 'delivered')
            .toList();

      case 'Cancelled':
        return orders
            .where(
              (order) =>
                  order.orderStatus.toLowerCase() == 'cancelled' ||
                  order.orderStatus.toLowerCase() == 'rejected' ||
                  order.orderStatus.toLowerCase() == 'refunded',
            )
            .toList();

      case 'All':
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (orderController.isLoading.value && orderController.orders.isEmpty) {
          return _buildLoadingState();
        }

        if (orderController.errorMessage.value.isNotEmpty &&
            orderController.orders.isEmpty) {
          return _buildErrorState();
        }

        return RefreshIndicator(
          color: const Color(0xFF6C4CF1),
          onRefresh: () async {
            _listenToOrders();

            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),

              SliverToBoxAdapter(child: _buildFilterBar()),

              if (filteredOrders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final order = filteredOrders[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _buildOrderCard(order),
                      );
                    }, childCount: filteredOrders.length),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FC),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        'My Orders',
        style: GoogleFonts.poppins(
          fontSize: 21.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF202020),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              Iconsax.receipt_item,
              color: const Color(0xFF6C4CF1),
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 18.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Track and manage your orders',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Obx(
            () => Text(
              '${orderController.orderCount} ${orderController.orderCount == 1 ? 'Order' : 'Orders'}',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C4CF1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C4CF1) : Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C4CF1)
                      : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.orderStatus.toLowerCase();
    final paymentStatus = order.paymentStatus.toLowerCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // TOP ROW
          // ----------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF202020),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(order.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              _buildStatusBadge(
                label: _formatStatus(order.orderStatus),
                status: status,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ----------------------------------------------------------
          // PRODUCT PREVIEW
          // ----------------------------------------------------------
          _buildProductPreview(order),

          SizedBox(height: 16.h),

          Divider(height: 1, color: Colors.grey.shade200),

          SizedBox(height: 14.h),

          // ----------------------------------------------------------
          // PAYMENT + TOTAL
          // ----------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _buildSmallInfo(
                  icon: Iconsax.wallet_2,
                  label: 'Payment',
                  value: _formatPaymentMethod(order.paymentMethod),
                ),
              ),
              Expanded(
                child: _buildSmallInfo(
                  icon: Iconsax.card,
                  label: 'Payment Status',
                  value: _formatStatus(order.paymentStatus),
                  valueColor: _paymentStatusColor(paymentStatus),
                ),
              ),
              Expanded(
                child: _buildSmallInfo(
                  icon: Iconsax.money,
                  label: 'Total',
                  value: 'Rs. ${order.total.toStringAsFixed(0)}',
                  valueBold: true,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ----------------------------------------------------------
          // VIEW DETAILS
          // ----------------------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed('/order-details', arguments: {'orderId': order.id});
              },
              icon: Icon(Iconsax.arrow_right_3, size: 18.sp),
              label: Text(
                'View Order Details',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6C4CF1),
                side: BorderSide(color: const Color(0xFF6C4CF1), width: 1.1.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview(OrderModel order) {
    final items = order.items;

    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FC),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Iconsax.box, color: Colors.grey.shade500, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              'No product information available',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final previewItems = items.take(2).toList();

    return Row(
      children: [
        ...previewItems.map(
          (item) => Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: _buildProductImage(item),
          ),
        ),

        if (items.length > 2)
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                '+${items.length - 2}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C4CF1),
                ),
              ),
            ),
          ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items.first.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(OrderItem item) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: item.productImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Iconsax.image,
                    size: 20.sp,
                    color: Colors.grey.shade500,
                  );
                },
              ),
            )
          : Icon(Iconsax.image, size: 20.sp, color: Colors.grey.shade500),
    );
  }

  Widget _buildSmallInfo({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF303030),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required String status}) {
    final color = _statusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38.w,
              height: 38.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF6C4CF1),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Loading your orders...',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4CF1).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.receipt_item,
                size: 42.sp,
                color: const Color(0xFF6C4CF1),
              ),
            ),

            SizedBox(height: 22.h),

            Text(
              selectedFilter == 'All'
                  ? 'No Orders Yet'
                  : 'No $selectedFilter Orders',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202020),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              selectedFilter == 'All'
                  ? 'Your orders will appear here once you make a purchase.'
                  : 'You do not have any orders in this category yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 22.h),

            SizedBox(
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.offAllNamed('/home');
                },
                icon: Icon(Iconsax.shopping_bag, size: 18.sp),
                label: Text(
                  'Start Shopping',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C4CF1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2, size: 50.sp, color: Colors.redAccent),

            SizedBox(height: 16.h),

            Text(
              'Unable to Load Orders',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              orderController.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 20.h),

            ElevatedButton(
              onPressed: _listenToOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4CF1),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);

      case 'accepted':
      case 'confirmed':
        return const Color(0xFF2563EB);

      case 'processing':
        return const Color(0xFF7C3AED);

      case 'dispatched':
      case 'out_for_delivery':
        return const Color(0xFF0891B2);

      case 'delivered':
        return const Color(0xFF16A34A);

      case 'cancelled':
      case 'rejected':
      case 'refunded':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return const Color(0xFF16A34A);

      case 'failed':
        return const Color(0xFFDC2626);

      case 'refunded':
        return const Color(0xFF7C3AED);

      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatStatus(String status) {
    if (status.trim().isEmpty) {
      return 'Unknown';
    }

    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatPaymentMethod(String method) {
    if (method.trim().isEmpty) {
      return 'Not specified';
    }

    return method;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${months[date.month - 1]} ${date.day}, ${date.year} • '
        '$hour:$minute $period';
  }
}
