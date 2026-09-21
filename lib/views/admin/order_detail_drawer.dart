import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controllers/admin_orders_controller.dart';
import 'package:e_commerce/models/order_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/admin_skeleton.dart';
import 'package:e_commerce/utills/custom_dialog.dart';
import 'package:e_commerce/utills/order_status_style.dart';
import 'package:e_commerce/utills/right_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the order detail drawer for [orderId]. Safe to call from Orders,
/// Dispatch, Payments or Returns — each just filters which actions it shows
/// by not needing to duplicate this panel.
Future<void> showOrderDetailDrawer({
  required BuildContext context,
  required String orderId,
  required AdminOrdersController controller,
}) {
  return showRightDrawer(
    context: context,
    maxWidth: 520,
    builder: (context) =>
        OrderDetailDrawer(orderId: orderId, controller: controller),
  );
}

class OrderDetailDrawer extends StatefulWidget {
  const OrderDetailDrawer({
    super.key,
    required this.orderId,
    required this.controller,
  });

  final String orderId;
  final AdminOrdersController controller;

  @override
  State<OrderDetailDrawer> createState() => _OrderDetailDrawerState();
}

class _OrderDetailDrawerState extends State<OrderDetailDrawer> {
  late final TextEditingController _noteController;
  bool _noteDirty = false;

  @override
  void initState() {
    super.initState();
    final order = widget.controller.byId(widget.orderId);
    _noteController = TextEditingController(text: order?.adminNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.canvas,
      child: Obx(() {
        final order = widget.controller.byId(widget.orderId);
        final busy = widget.controller.busyOrderId.value == widget.orderId;

        if (order == null) {
          return Column(
            children: [
              _DrawerTopBar(title: 'Order', onClose: () => Get.back()),
              const Expanded(child: AdminDetailSkeleton()),
            ],
          );
        }

        return Column(
          children: [
            _DrawerTopBar(
              title: AdminFormat.orderRef(order.id),
              subtitle: AdminFormat.dateTimeShort(order.createdAt),
              onClose: () => Get.back(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _StatusHero(order: order),
                  const SizedBox(height: 18),
                  _StatusTimeline(order: order),
                  const SizedBox(height: 18),
                  _CustomerCard(order: order),
                  const SizedBox(height: 18),
                  _ItemsCard(order: order),
                  const SizedBox(height: 18),
                  _PaymentCard(
                    order: order,
                    busy: busy,
                    controller: widget.controller,
                  ),
                  const SizedBox(height: 18),
                  _NoteCard(
                    controller: _noteController,
                    dirty: _noteDirty,
                    busy: busy,
                    onChanged: () => setState(() => _noteDirty = true),
                    onSave: () async {
                      final ok = await widget.controller.saveAdminNote(
                        order.id,
                        _noteController.text,
                      );
                      if (ok) setState(() => _noteDirty = false);
                    },
                  ),
                ],
              ),
            ),
            _ActionBar(order: order, busy: busy, controller: widget.controller),
          ],
        );
      }),
    );
  }
}

// ===========================================================================
// TOP BAR
// ===========================================================================

class _DrawerTopBar extends StatelessWidget {
  const _DrawerTopBar({
    required this.title,
    this.subtitle,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AdminText.display(19)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AdminText.body(12, color: AdminColors.muted),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// STATUS HERO
// ===========================================================================

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusStyle.foreground(order.orderStatus);
    final bg = OrderStatusStyle.background(order.orderStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              OrderStatusStyle.icon(order.orderStatus),
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  OrderStatusStyle.label(order.orderStatus),
                  style: AdminText.display(17, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · '
                  '${AdminFormat.money(order.total, currency: order.currency)}',
                  style: AdminText.body(12.5, color: AdminColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 260));
  }
}

// ===========================================================================
// STATUS TIMELINE
// ===========================================================================

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled || order.isRejected) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.dangerTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              color: AdminColors.danger,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${order.isRejected ? 'Rejected' : 'Cancelled'} · '
                '${AdminFormat.dateTimeShort(order.cancelledAt)}',
                style: AdminText.body(
                  12.5,
                  color: AdminColors.danger,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final steps = <(String, IconData, DateTime?)>[
      ('Placed', Icons.receipt_long_rounded, order.createdAt),
      ('Accepted', Icons.check_circle_outline_rounded, order.acceptedAt),
      ('Dispatched', Icons.local_shipping_outlined, order.dispatchedAt),
      ('Delivered', Icons.task_alt_rounded, order.deliveredAt),
    ];

    final int activeIndex = steps.lastIndexWhere((s) => s.$3 != null);

    return AdminSectionCardLite(
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i != 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= activeIndex
                      ? AdminColors.brass
                      : AdminColors.line,
                ),
              ),
            _TimelineDot(
              label: steps[i].$1,
              icon: steps[i].$2,
              time: steps[i].$3,
              done: i <= activeIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.label,
    required this.icon,
    required this.time,
    required this.done,
  });

  final String label;
  final IconData icon;
  final DateTime? time;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: done ? AdminColors.brass : AdminColors.line,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: done ? Colors.white : AdminColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AdminText.body(
            10.5,
            weight: FontWeight.w600,
            color: done ? AdminColors.inkSoft : AdminColors.muted,
          ),
        ),
        if (time != null)
          Text(
            AdminFormat.dateShort(time),
            style: AdminText.body(9.5, color: AdminColors.muted),
          ),
      ],
    );
  }
}

/// A section card without the title row, for compact blocks like the
/// timeline that don't need a heading.
class AdminSectionCardLite extends StatelessWidget {
  const AdminSectionCardLite({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.line),
      ),
      child: child,
    );
  }
}

// ===========================================================================
// CUSTOMER + SHIPPING
// ===========================================================================

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress;

    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminSwatch(
                seed: address.fullName.isEmpty ? 'Guest' : address.fullName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      address.fullName.isEmpty
                          ? 'Guest customer'
                          : address.fullName,
                      style: AdminText.body(14, weight: FontWeight.w600),
                    ),
                    if (address.phone.isNotEmpty)
                      Text(
                        address.phone,
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                  ],
                ),
              ),
              if (address.phone.isNotEmpty)
                _IconChip(
                  icon: Icons.call_outlined,
                  tooltip: 'Call customer',
                  onTap: () => launchUrl(Uri.parse('tel:${address.phone}')),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AdminColors.line),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: AdminColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.formattedAddress.isEmpty
                      ? 'No shipping address on file.'
                      : address.formattedAddress,
                  style: AdminText.body(
                    12.5,
                    color: AdminColors.inkSoft,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              if (address.formattedAddress.isNotEmpty)
                _IconChip(
                  icon: Icons.copy_rounded,
                  tooltip: 'Copy address',
                  onTap: () => Clipboard.setData(
                    ClipboardData(text: address.formattedAddress),
                  ),
                ),
            ],
          ),
          if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AdminColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15,
                    color: AdminColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerNote!,
                      style: AdminText.body(12, color: AdminColors.inkSoft),
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

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AdminColors.brassTint,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 15, color: AdminColors.brassDark),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ITEMS
// ===========================================================================

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in order.items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: item.productImage.isEmpty
                        ? AdminSwatch(seed: item.productName, size: 40)
                        : CachedNetworkImage(
                            imageUrl: item.productImage,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                AdminSwatch(seed: item.productName, size: 40),
                            placeholder: (_, __) => AdminSkeleton.shimmer(
                              child: AdminSkeleton.block(
                                width: 40,
                                height: 40,
                                radius: 9,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.productName,
                          overflow: TextOverflow.ellipsis,
                          style: AdminText.body(13, weight: FontWeight.w600),
                        ),
                        if (item.hasVariation)
                          Text(
                            item.variationDisplayName,
                            style: AdminText.body(
                              11.5,
                              color: AdminColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.quantity} × ${AdminFormat.money(item.price, currency: order.currency)}',
                    style: AdminText.body(12, color: AdminColors.muted),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1, color: AdminColors.line),
          const SizedBox(height: 10),
          _TotalsLine(
            label: 'Subtotal',
            value: order.subtotal,
            currency: order.currency,
          ),
          if (order.hasDiscount)
            _TotalsLine(
              label: 'Discount',
              value: -order.discount,
              currency: order.currency,
            ),
          if (order.hasShippingFee)
            _TotalsLine(
              label: 'Shipping',
              value: order.shippingFee,
              currency: order.currency,
            ),
          const SizedBox(height: 4),
          _TotalsLine(
            label: 'Total',
            value: order.total,
            currency: order.currency,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _TotalsLine extends StatelessWidget {
  const _TotalsLine({
    required this.label,
    required this.value,
    required this.currency,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final String currency;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AdminText.body(
              emphasize ? 13.5 : 12.5,
              weight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize ? AdminColors.ink : AdminColors.muted,
            ),
          ),
          const Spacer(),
          Text(
            AdminFormat.money(value, currency: currency),
            style: AdminText.body(
              emphasize ? 14.5 : 12.5,
              weight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PAYMENT
// ===========================================================================

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.order,
    required this.busy,
    required this.controller,
  });

  final OrderModel order;
  final bool busy;
  final AdminOrdersController controller;

  String get _methodLabel {
    switch (order.paymentMethod) {
      case 'stripe':
        return 'Card · Stripe';
      case 'payfast':
        return 'PayFast';
      case 'cash_on_delivery':
        return 'Cash on delivery';
      default:
        return order.paymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool codUnpaid =
        order.paymentMethod == 'cash_on_delivery' && !order.isPaid;

    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Payment',
                      style: AdminText.body(
                        12.5,
                        weight: FontWeight.w700,
                        color: AdminColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _methodLabel,
                      style: AdminText.body(13.5, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PaymentStatusStyle.badge(order.paymentStatus),
            ],
          ),
          if (order.transactionId != null &&
              order.transactionId!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Transaction · ${order.transactionId}',
              style: AdminText.body(11.5, color: AdminColors.muted),
            ),
          ],
          if (codUnpaid) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AdminGhostButton(
                label: busy ? 'Updating…' : 'Mark as paid (cash received)',
                onPressed: busy
                    ? null
                    : () => controller.setPaymentStatus(order.id, 'paid'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// ADMIN NOTE
// ===========================================================================

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.controller,
    required this.dirty,
    required this.busy,
    required this.onChanged,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool dirty;
  final bool busy;
  final VoidCallback onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Internal note',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            maxLines: 3,
            style: AdminText.body(13),
            decoration: InputDecoration(
              hintText: 'Only visible to your team…',
              hintStyle: AdminText.body(12.5, color: AdminColors.muted),
              isDense: true,
              filled: true,
              fillColor: AdminColors.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (dirty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: AdminPrimaryButton(
                label: 'Save note',
                loading: busy,
                onPressed: onSave,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// ACTION BAR
// ===========================================================================

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.busy,
    required this.controller,
  });

  final OrderModel order;
  final bool busy;
  final AdminOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(top: BorderSide(color: AdminColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: order.orderStatus == OrderStatuses.pending
            ? Row(
                children: [
                  Expanded(
                    child: AdminGhostButton(
                      label: 'Reject',
                      onPressed: busy
                          ? null
                          : () => CustomDialog.delete(
                              context,
                              title: 'Reject this order?',
                              message:
                                  'The customer will be notified the order was rejected.',
                              deleteText: 'Reject',
                              onDelete: () => controller.rejectOrder(order.id),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AdminPrimaryButton(
                      label: 'Accept order',
                      icon: Icons.check_rounded,
                      loading: busy,
                      onPressed: () => controller.acceptOrder(order.id),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  if (order.canBeCancelled)
                    Expanded(
                      child: AdminGhostButton(
                        label: 'Cancel order',
                        onPressed: busy
                            ? null
                            : () => CustomDialog.delete(
                                context,
                                title: 'Cancel this order?',
                                message:
                                    'This cannot be undone. The customer will be notified.',
                                deleteText: 'Cancel order',
                                onDelete: () =>
                                    controller.cancelOrder(order.id),
                              ),
                      ),
                    ),
                  if (order.canBeCancelled) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _StatusMenuButton(
                      order: order,
                      busy: busy,
                      controller: controller,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusMenuButton extends StatelessWidget {
  const _StatusMenuButton({
    required this.order,
    required this.busy,
    required this.controller,
  });

  final OrderModel order;
  final bool busy;
  final AdminOrdersController controller;

  static const _destructive = {OrderStatuses.cancelled, OrderStatuses.rejected};

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: !busy,
      tooltip: 'Change status',
      offset: const Offset(0, -220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final status in OrderStatuses.all)
          if (status != order.orderStatus)
            PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    OrderStatusStyle.icon(status),
                    size: 16,
                    color: OrderStatusStyle.foreground(status),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    OrderStatusStyle.label(status),
                    style: AdminText.body(13),
                  ),
                ],
              ),
            ),
      ],
      onSelected: (status) {
        if (_destructive.contains(status)) {
          CustomDialog.delete(
            context,
            title: 'Set status to ${OrderStatusStyle.label(status)}?',
            message: 'The customer will see this change on their order.',
            deleteText: 'Confirm',
            onDelete: () => controller.setStatus(order.id, status),
          );
        } else {
          controller.setStatus(order.id, status);
        }
      },
      child: IgnorePointer(
        child: AdminPrimaryButton(
          label: 'Update status',
          icon: Icons.sync_alt_rounded,
          loading: busy,
          onPressed: () {},
        ),
      ),
    );
  }
}
