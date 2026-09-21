import 'package:e_commerce/models/order_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/order_status_style.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';

class OrderRow extends StatelessWidget {
  const OrderRow({
    super.key,
    required this.order,
    required this.customerName,
    required this.busy,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final OrderModel order;
  final String customerName;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? _MobileCard(
            order: order,
            customerName: customerName,
            busy: busy,
            onTap: onTap,
            onAccept: onAccept,
            onReject: onReject,
          )
        : _DesktopRow(
            order: order,
            customerName: customerName,
            busy: busy,
            onTap: onTap,
            onAccept: onAccept,
            onReject: onReject,
          );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          icon: Icons.check_rounded,
          color: AdminColors.success,
          tint: AdminColors.successTint,
          tooltip: 'Accept order',
          onTap: onAccept,
        ),
        const SizedBox(width: 6),
        _RoundIconButton(
          icon: Icons.close_rounded,
          color: AdminColors.danger,
          tint: AdminColors.dangerTint,
          tooltip: 'Reject order',
          onTap: onReject,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.tint,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: tint,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({
    required this.order,
    required this.customerName,
    required this.busy,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final OrderModel order;
  final String customerName;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  AdminSwatch(seed: customerName),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AdminFormat.orderRef(order.id),
                          style: AdminText.body(13.5, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customerName,
                          overflow: TextOverflow.ellipsis,
                          style: AdminText.body(12, color: AdminColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                style: AdminText.body(13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AdminFormat.money(order.total, currency: order.currency),
                style: AdminText.body(13, weight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: PaymentStatusStyle.badge(order.paymentStatus),
            ),
            Expanded(flex: 2, child: OrderStatusStyle.badge(order.orderStatus)),
            Expanded(
              flex: 2,
              child: Text(
                AdminFormat.relative(order.createdAt),
                style: AdminText.body(12, color: AdminColors.muted),
              ),
            ),
            SizedBox(
              width: 78,
              child: order.orderStatus == OrderStatuses.pending
                  ? _QuickActions(
                      busy: busy,
                      onAccept: onAccept,
                      onReject: onReject,
                    )
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AdminColors.muted.withValues(alpha: 0.6),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.order,
    required this.customerName,
    required this.busy,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final OrderModel order;
  final String customerName;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdminSwatch(seed: customerName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AdminFormat.orderRef(order.id),
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customerName,
                        overflow: TextOverflow.ellipsis,
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
                OrderStatusStyle.badge(order.orderStatus),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AdminColors.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · '
                  '${AdminFormat.relative(order.createdAt)}',
                  style: AdminText.body(12, color: AdminColors.muted),
                ),
                const Spacer(),
                Text(
                  AdminFormat.money(order.total, currency: order.currency),
                  style: AdminText.body(14, weight: FontWeight.w700),
                ),
              ],
            ),
            if (order.orderStatus == OrderStatuses.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MobileActionButton(
                      label: 'Reject',
                      color: AdminColors.danger,
                      background: AdminColors.dangerTint,
                      busy: busy,
                      onTap: onReject,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MobileActionButton(
                      label: 'Accept',
                      color: Colors.white,
                      background: AdminColors.success,
                      busy: busy,
                      onTap: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileActionButton extends StatelessWidget {
  const _MobileActionButton({
    required this.label,
    required this.color,
    required this.background,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color background;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: busy ? null : onTap,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          child: busy
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  label,
                  style: AdminText.body(
                    13,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}
