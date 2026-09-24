import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/return_controller.dart';
import '../../models/order_model.dart';
import '../../models/return_request_model.dart';
import '../../utills/customer_skeleton.dart';

const Color _ink = Color(0xFF202020);
const Color _accent = Color(0xFF6C4CF1);

class ReturnScreen extends GetView<ReturnController> {
  const ReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: Text(
          'Returns & Refunds',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isInitialLoading) {
          return const _ReturnSkeleton();
        }

        return Column(
          children: [
            _ModeToggle(),
            Expanded(
              child: Obx(() {
                return controller.viewMode.value == 0
                    ? const _NewRequestBody()
                    : const _HistoryBody();
              }),
            ),
          ],
        );
      }),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MODE TOGGLE                                                               */
/* -------------------------------------------------------------------------- */

class _ModeToggle extends GetView<ReturnController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBFB),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _ToggleTab(
                      label: 'New Request',
                      selected: controller.viewMode.value == 0,
                      onTap: () => controller.setViewMode(0),
                    ),
                  ),
                  Expanded(
                    child: _ToggleTab(
                      label: 'My Requests',
                      selected: controller.viewMode.value == 1,
                      onTap: () => controller.setViewMode(1),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? _accent : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* NEW REQUEST — ROOT                                                        */
/* -------------------------------------------------------------------------- */

class _NewRequestBody extends GetView<ReturnController> {
  const _NewRequestBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.submittedRequestId.value.isNotEmpty) {
        return const _SuccessView();
      }

      if (controller.selectedOrder.value == null) {
        return const _OrderPicker();
      }

      return const _ReturnForm();
    });
  }
}

/* -------------------------------------------------------------------------- */
/* STEP 1 — ORDER PICKER                                                     */
/* -------------------------------------------------------------------------- */

class _OrderPicker extends GetView<ReturnController> {
  const _OrderPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final orders = controller.deliveredOrders;

      if (orders.isEmpty) {
        return _EmptyState(
          icon: Iconsax.box_remove,
          title: 'No delivered orders yet',
          message:
              'Once an order is delivered, you\'ll be able to request a return for it here.',
        );
      }

      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select an order to return',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Returns are accepted within ${ReturnController.returnWindowDays} days of delivery.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 16.h),
                ...orders.map(
                  (order) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _OrderPickerTile(order: order),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _OrderPickerTile extends GetView<ReturnController> {
  final OrderModel order;

  const _OrderPickerTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final ineligibleReason = controller.ineligibilityReason(order);
    final eligible = ineligibleReason == null;

    return Opacity(
      opacity: eligible ? 1 : .55,
      child: InkWell(
        onTap: eligible ? () => controller.selectOrder(order) : null,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: Stack(
                  children: order.items.take(2).toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final item = entry.value;

                    return Positioned(
                      left: index * 12.w,
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: item.productImage.isEmpty
                            ? Icon(
                                Iconsax.image,
                                size: 16.sp,
                                color: Colors.grey.shade400,
                              )
                            : CachedNetworkImage(
                                imageUrl: item.productImage,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    Container(color: Colors.grey.shade100),
                                errorWidget: (_, __, ___) => Icon(
                                  Iconsax.image,
                                  size: 16.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${order.itemCount} item(s) · Rs. ${order.total.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (order.deliveredAt != null) ...[
                      SizedBox(height: 3.h),
                      Text(
                        'Delivered ${_formatDate(order.deliveredAt!)}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (eligible)
                Icon(
                  Iconsax.arrow_right_3,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    ineligibleReason!,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* STEP 2 — RETURN FORM                                                      */
/* -------------------------------------------------------------------------- */

class _ReturnForm extends GetView<ReturnController> {
  const _ReturnForm();

  @override
  Widget build(BuildContext context) {
    final order = controller.selectedOrder.value!;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 35.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: controller.clearSelectedOrder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.arrow_left_2, size: 15.sp, color: _accent),
                    SizedBox(width: 4.w),
                    Text(
                      'Change order · #${order.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              _sectionCard(
                title: 'Select items to return',
                child: Column(
                  children: order.items
                      .map((item) => _ReturnItemRow(item: item))
                      .toList(),
                ),
              ),

              SizedBox(height: 14.h),

              _sectionCard(
                title: 'Reason for return',
                child: Obx(() {
                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ReturnReasons.all.map((label) {
                      final selected = controller.reason.value == label;

                      return InkWell(
                        onTap: () => controller.setReason(label),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 9.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? _accent.withValues(alpha: .1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: selected ? _accent : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: selected ? _accent : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),

              SizedBox(height: 14.h),

              _sectionCard(
                title: 'Preferred resolution',
                child: Obx(() {
                  return Row(
                    children: [
                      _ResolutionOption(
                        label: 'Refund',
                        icon: Iconsax.wallet_money,
                        value: 'refund',
                        selected: controller.resolution.value == 'refund',
                      ),
                      SizedBox(width: 10.w),
                      _ResolutionOption(
                        label: 'Exchange',
                        icon: Iconsax.repeat,
                        value: 'exchange',
                        selected: controller.resolution.value == 'exchange',
                      ),
                      SizedBox(width: 10.w),
                      _ResolutionOption(
                        label: 'Store Credit',
                        icon: Iconsax.card,
                        value: 'store_credit',
                        selected: controller.resolution.value == 'store_credit',
                      ),
                    ],
                  );
                }),
              ),

              SizedBox(height: 14.h),

              _sectionCard(
                title: 'Additional details (optional)',
                child: TextField(
                  onChanged: controller.setDescription,
                  maxLines: 4,
                  style: GoogleFonts.poppins(fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText:
                        'Tell us a bit more about the issue — this helps us process your return faster.',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F8FA),
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              _sectionCard(
                title: 'Photos (optional)',
                subtitle: 'Add up to 4 photos — helpful for damaged items.',
                child: const _PhotoPicker(),
              ),

              SizedBox(height: 22.h),

              _SubmitBar(order: order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _ReturnItemRow extends GetView<ReturnController> {
  final OrderItem item;

  const _ReturnItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isItemSelected(item.productId);
      final quantity =
          controller.selectedQuantities[item.productId] ?? item.quantity;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: InkWell(
          onTap: () => controller.toggleItem(item),
          borderRadius: BorderRadius.circular(12.r),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                activeColor: _accent,
                onChanged: (_) => controller.toggleItem(item),
              ),
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.productImage.isEmpty
                    ? Icon(
                        Iconsax.image,
                        size: 18.sp,
                        color: Colors.grey.shade400,
                      )
                    : CachedNetworkImage(
                        imageUrl: item.productImage,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade100),
                        errorWidget: (_, __, ___) => Icon(
                          Iconsax.image,
                          size: 18.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    if (item.hasVariation)
                      Text(
                        item.variationDisplayName,
                        style: GoogleFonts.poppins(
                          fontSize: 9.5.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    Text(
                      'Rs. ${item.price.toStringAsFixed(0)} · Qty ordered: ${item.quantity}',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected && item.quantity > 1)
                _QuantityStepper(
                  quantity: quantity,
                  onDecrease: () =>
                      controller.setItemQuantity(item, quantity - 1),
                  onIncrease: () =>
                      controller.setItemQuantity(item, quantity + 1),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(Iconsax.minus, onDecrease),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              '$quantity',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _stepperButton(Iconsax.add, onIncrease),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, size: 12.sp),
      ),
    );
  }
}

class _ResolutionOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;

  const _ResolutionOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReturnController>();

    return Expanded(
      child: InkWell(
        onTap: () => controller.setResolution(value),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? _accent.withValues(alpha: .1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: selected ? _accent : Colors.transparent),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: selected ? _accent : Colors.grey.shade600,
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? _accent : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends GetView<ReturnController> {
  const _PhotoPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final urls = controller.photoUrls;
      final uploading = controller.isUploadingPhotos.value;

      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          ...urls.map(
            (url) => Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade100,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade100),
                    errorWidget: (_, __, ___) => Icon(
                      Iconsax.image,
                      size: 18.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: InkWell(
                    onTap: () => controller.removePhoto(url),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (urls.length < 4)
            InkWell(
              onTap: uploading ? null : controller.pickAndUploadPhotos,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: uploading
                    ? Center(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Icon(
                        Iconsax.camera,
                        size: 20.sp,
                        color: Colors.grey.shade500,
                      ),
              ),
            ),
        ],
      );
    });
  }
}

class _SubmitBar extends GetView<ReturnController> {
  final OrderModel order;

  const _SubmitBar({required this.order});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final estimatedRefund = order.items.fold<double>(0, (total, item) {
        final quantity = controller.selectedQuantities[item.productId];
        if (quantity == null) return total;
        return total + item.price * quantity;
      });

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated refund',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Rs. ${estimatedRefund.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: controller.canSubmit
                    ? () => controller.submitRequest()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Return Request',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/* -------------------------------------------------------------------------- */
/* SUCCESS VIEW                                                              */
/* -------------------------------------------------------------------------- */

class _SuccessView extends GetView<ReturnController> {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480.w),
          child: Column(
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.tick_circle5,
                  color: const Color(0xFF10B981),
                  size: 42.sp,
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Return Request Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We\'ll review your request and get back to you within 2-3 business days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => controller.setViewMode(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Track My Requests',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: controller.startAnotherRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'File Another Return',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HISTORY                                                                   */
/* -------------------------------------------------------------------------- */

class _HistoryBody extends GetView<ReturnController> {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReturns.value && controller.myReturns.isEmpty) {
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
          itemCount: 3,
          itemBuilder: (_, __) => const _ReturnHistorySkeletonCard(),
        );
      }

      if (controller.myReturns.isEmpty) {
        return _EmptyState(
          icon: Iconsax.receipt_item,
          title: 'No return requests yet',
          message: 'Requests you file will show up here with their status.',
        );
      }

      return Center(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
          itemCount: controller.myReturns.length,
          itemBuilder: (context, index) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700.w),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ReturnHistoryCard(
                    request: controller.myReturns[index],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ReturnHistoryCard extends StatelessWidget {
  final ReturnRequestModel request;

  const _ReturnHistoryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${request.orderId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${request.itemCount} item(s) · ${request.reason}',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          if (request.createdAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Requested ${_formatDate(request.createdAt!)}',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Est. refund',
                style: GoogleFonts.poppins(
                  fontSize: 10.5.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                'Rs. ${request.estimatedRefund.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
          if (request.adminNote != null &&
              request.adminNote!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2FC),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note from our team',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    request.adminNote!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: _ink,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: style.$1.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        style.$2,
        style: GoogleFonts.poppins(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: style.$1,
        ),
      ),
    );
  }

  (Color, String) _styleFor(String status) {
    switch (status) {
      case 'approved':
        return (const Color(0xFF2563EB), 'Approved');
      case 'rejected':
        return (const Color(0xFFDC2626), 'Rejected');
      case 'completed':
        return (const Color(0xFF10B981), 'Completed');
      default:
        return (const Color(0xFFF59E0B), 'Pending');
    }
  }
}

class _ReturnHistorySkeletonCard extends StatelessWidget {
  const _ReturnHistorySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomerSkeleton.shimmer(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerSkeleton.block(width: 140.w, height: 13.h),
              SizedBox(height: 10.h),
              CustomerSkeleton.block(width: 200.w, height: 10.h),
              SizedBox(height: 8.h),
              CustomerSkeleton.block(width: 120.w, height: 9.h),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SHARED EMPTY STATE + SKELETON                                             */
/* -------------------------------------------------------------------------- */

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52.sp, color: Colors.grey.shade400),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnSkeleton extends StatelessWidget {
  const _ReturnSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 30.h),
      children: [
        CustomerSkeleton.shimmer(
          child: CustomerSkeleton.block(height: 46.h, radius: 14.r),
        ),
        SizedBox(height: 20.h),
        ...List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CustomerSkeleton.shimmer(
              child: CustomerSkeleton.block(height: 84.h, radius: 16.r),
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HELPERS                                                                   */
/* -------------------------------------------------------------------------- */

String _formatDate(DateTime date) {
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

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
