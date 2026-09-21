import 'package:e_commerce/controllers/order_controller.dart';
import 'package:e_commerce/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/constants/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrderController orderController;

  OrderModel? order;
  bool isLoading = true;
  bool isCancelling = false;

  @override
  void initState() {
    super.initState();

    orderController = Get.find<OrderController>();

    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final orderId = args['orderId']?.toString() ?? '';

    if (orderId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final existingOrder = orderController.getOrderFromList(orderId);

    if (existingOrder != null) {
      setState(() {
        order = existingOrder;
        isLoading = false;
      });
      return;
    }

    final loadedOrder = await orderController.getOrder(orderId);

    if (!mounted) {
      return;
    }

    setState(() {
      order = loadedOrder;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (order == null) {
      return _buildNotFoundScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: Obx(() {
        final latestOrder = orderController.getOrderFromList(order!.id);

        if (latestOrder != null) {
          order = latestOrder;
        }

        return _buildBody(order!);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FC),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Iconsax.arrow_left,
          size: 22.sp,
          color: const Color(0xFF202020),
        ),
      ),
      title: Text(
        'Order Details',
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF202020),
        ),
      ),
    );
  }

  Widget _buildBody(OrderModel order) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 35.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 850.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),

              SizedBox(height: 16.h),

              _buildTrackingCard(order),

              SizedBox(height: 16.h),

              _buildProductsCard(order),

              SizedBox(height: 16.h),

              _buildPriceSummary(order),

              SizedBox(height: 16.h),

              _buildPaymentCard(order),

              SizedBox(height: 16.h),

              _buildAddressCard(order),

              if (order.canBeCancelled) ...[
                SizedBox(height: 20.h),
                _buildCancelButton(order),
              ],

              if (order.isDelivered) ...[
                SizedBox(height: 20.h),
                _buildReturnButton(order),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFF6C4CF1).withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Iconsax.receipt_item,
              color: const Color(0xFF6C4CF1),
              size: 25.sp,
            ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
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
            _formatStatus(order.orderStatus),
            _statusColor(order.orderStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Iconsax.truck_fast, title: 'Order Tracking'),

          SizedBox(height: 22.h),

          _buildTimeline(order),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final currentStatus = order.orderStatus.toLowerCase();

    final steps = [
      _TrackingStep(
        title: 'Order Placed',
        subtitle: 'Your order has been received',
        status: 'pending',
        completed: true,
        active: currentStatus == 'pending',
      ),
      _TrackingStep(
        title: 'Confirmed',
        subtitle: 'Your order has been confirmed',
        status: 'confirmed',
        completed: _statusReached(currentStatus, 1),
        active: currentStatus == 'accepted' || currentStatus == 'confirmed',
      ),
      _TrackingStep(
        title: 'Processing',
        subtitle: 'Your order is being prepared',
        status: 'processing',
        completed: _statusReached(currentStatus, 2),
        active: currentStatus == 'processing',
      ),
      _TrackingStep(
        title: 'Dispatched',
        subtitle: 'Your order is on its way',
        status: 'dispatched',
        completed: _statusReached(currentStatus, 3),
        active: currentStatus == 'dispatched',
      ),
      _TrackingStep(
        title: 'Out for Delivery',
        subtitle: 'Your order is with the delivery partner',
        status: 'out_for_delivery',
        completed: _statusReached(currentStatus, 4),
        active: currentStatus == 'out_for_delivery',
      ),
      _TrackingStep(
        title: 'Delivered',
        subtitle: 'Your order has been delivered',
        status: 'delivered',
        completed: currentStatus == 'delivered',
        active: currentStatus == 'delivered',
      ),
    ];

    if (currentStatus == 'cancelled' ||
        currentStatus == 'rejected' ||
        currentStatus == 'refunded') {
      return _buildCancelledTimeline(order);
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];

        return _buildTimelineItem(
          step: step,
          isLast: index == steps.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineItem({
    required _TrackingStep step,
    required bool isLast,
  }) {
    final color = step.completed || step.active
        ? const Color(0xFF6C4CF1)
        : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32.w,
            child: Column(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.completed
                        ? const Color(0xFF6C4CF1)
                        : Colors.white,
                    border: Border.all(color: color, width: 2.w),
                  ),
                  child: step.completed
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        )
                      : step.active
                      ? Container(
                          margin: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF6C4CF1),
                          ),
                        )
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 3.h),
                      color: step.completed
                          ? const Color(0xFF6C4CF1)
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: step.active || step.completed
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: step.active || step.completed
                          ? const Color(0xFF202020)
                          : Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    step.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: step.active || step.completed
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledTimeline(OrderModel order) {
    final status = order.orderStatus.toLowerCase();

    final title = status == 'refunded'
        ? 'Order Refunded'
        : status == 'rejected'
        ? 'Order Rejected'
        : 'Order Cancelled';

    final subtitle = status == 'refunded'
        ? 'The order amount has been refunded.'
        : status == 'rejected'
        ? 'This order was rejected.'
        : 'This order has been cancelled.';

    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: Colors.red.shade600,
            size: 23.sp,
          ),
        ),

        SizedBox(width: 14.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
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

  Widget _buildProductsCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Iconsax.shopping_bag, title: 'Products'),

          SizedBox(height: 16.h),

          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Column(
              children: [
                _buildOrderItem(item),

                if (index != order.items.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Divider(height: 1, color: Colors.grey.shade200),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 68.w,
          height: 68.w,
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
                        color: Colors.grey.shade500,
                        size: 25.sp,
                      );
                    },
                  ),
                )
              : Icon(Iconsax.image, color: Colors.grey.shade500, size: 25.sp),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),

              if (item.hasVariation) ...[
                SizedBox(height: 4.h),
                Text(
                  item.variationDisplayName,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              SizedBox(height: 5.h),

              Text(
                'Qty: ${item.quantity}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 10.w),

        Text(
          'Rs. ${item.total.toStringAsFixed(0)}',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(OrderModel order) {
    return _card(
      child: Column(
        children: [
          _sectionTitle(icon: Iconsax.receipt_2, title: 'Order Summary'),

          SizedBox(height: 18.h),

          _priceRow('Subtotal', 'Rs. ${order.subtotal.toStringAsFixed(0)}'),

          SizedBox(height: 10.h),

          _priceRow(
            'Shipping',
            order.shippingFee <= 0
                ? 'Free'
                : 'Rs. ${order.shippingFee.toStringAsFixed(0)}',
          ),

          if (order.discount > 0) ...[
            SizedBox(height: 10.h),
            _priceRow(
              'Discount',
              '- Rs. ${order.discount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF16A34A),
            ),
          ],

          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),

          _priceRow(
            'Total',
            'Rs. ${order.total.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Iconsax.wallet_2, title: 'Payment'),

          SizedBox(height: 16.h),

          _detailRow('Payment Method', order.paymentMethod),

          SizedBox(height: 12.h),

          _detailRow(
            'Payment Status',
            _formatStatus(order.paymentStatus),
            valueColor: _paymentStatusColor(order.paymentStatus),
          ),

          if (order.transactionId != null &&
              order.transactionId!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _detailRow('Transaction ID', order.transactionId!),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderModel order) {
    final address = order.shippingAddress;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Iconsax.location, title: 'Delivery Address'),

          SizedBox(height: 16.h),

          Text(
            address.fullName,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202020),
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            address.phone,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            address.formattedAddress,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(OrderModel order) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: isCancelling ? null : () => _cancelOrder(order),
        icon: isCancelling
            ? SizedBox(
                width: 17.w,
                height: 17.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : Icon(Iconsax.close_circle, size: 18.sp),
        label: Text(
          isCancelling ? 'Cancelling...' : 'Cancel Order',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnButton(OrderModel order) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.toNamed(
            AppRoutes.productReturn,
            arguments: {'orderId': order.id},
          );
        },
        icon: Icon(Iconsax.refresh_circle, size: 18.sp),
        label: Text(
          'Request Return',
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6C4CF1),
          side: const BorderSide(color: Color(0xFF6C4CF1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Order?',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'No',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isCancelling = true;
    });

    final success = await orderController.cancelOrder(order.id);

    if (!mounted) {
      return;
    }

    setState(() {
      isCancelling = false;
    });

    if (success) {
      Get.snackbar(
        'Order Cancelled',
        'Your order has been cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF202020),
        colorText: Colors.white,
        margin: EdgeInsets.all(14.r),
        borderRadius: 12.r,
      );
    }
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: const Color(0xFF6C4CF1).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF6C4CF1)),
        ),

        SizedBox(width: 10.w),

        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 14.sp : 12.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? const Color(0xFF202020) : Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16.sp : 12.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color:
                valueColor ??
                (isTotal ? const Color(0xFF6C4CF1) : const Color(0xFF303030)),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF303030),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C4CF1)),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.receipt_minus,
                size: 55.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 18.h),
              Text(
                'Order Not Found',
                style: GoogleFonts.poppins(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We could not find this order.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C4CF1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _statusReached(String status, int step) {
    const order = [
      'pending',
      'accepted',
      'confirmed',
      'processing',
      'dispatched',
      'out_for_delivery',
      'delivered',
    ];

    final normalized = status.toLowerCase();

    int currentIndex = order.indexOf(normalized);

    if (normalized == 'confirmed') {
      currentIndex = 1;
    }

    if (currentIndex < 0) {
      return false;
    }

    return currentIndex >= step;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
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
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF16A34A);

      case 'failed':
        return const Color(0xFFDC2626);

      case 'refunded':
        return const Color(0xFF7C3AED);

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

class _TrackingStep {
  final String title;
  final String subtitle;
  final String status;
  final bool completed;
  final bool active;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.completed,
    required this.active,
  });
}
