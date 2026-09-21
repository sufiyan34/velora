import 'package:flutter/material.dart';

import '../theme/admin_theme.dart';
import 'admin_badge.dart';

/// The order lifecycle, in the sequence the spec defines it.
/// `orderStatus` strings in RTDB are exactly these values.
class OrderStatuses {
  OrderStatuses._();

  static const pending = 'pending';
  static const accepted = 'accepted';
  static const processing = 'processing';
  static const dispatched = 'dispatched';
  static const outForDelivery = 'outForDelivery';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';
  static const rejected = 'rejected';

  /// Full lifecycle, in order — used for pipelines and status pickers.
  static const all = <String>[
    pending,
    accepted,
    processing,
    dispatched,
    outForDelivery,
    delivered,
    cancelled,
    rejected,
  ];

  /// Statuses that count as revenue (cancelled / rejected are excluded).
  static const earning = <String>[
    pending,
    accepted,
    processing,
    dispatched,
    outForDelivery,
    delivered,
  ];

  static bool isClosed(String status) =>
      status == delivered || status == cancelled || status == rejected;
}

class OrderStatusStyle {
  OrderStatusStyle._();

  static String label(String status) {
    switch (status) {
      case OrderStatuses.pending:
        return 'Pending';
      case OrderStatuses.accepted:
        return 'Accepted';
      case OrderStatuses.processing:
        return 'Processing';
      case OrderStatuses.dispatched:
        return 'Dispatched';
      case OrderStatuses.outForDelivery:
        return 'Out for delivery';
      case OrderStatuses.delivered:
        return 'Delivered';
      case OrderStatuses.cancelled:
        return 'Cancelled';
      case OrderStatuses.rejected:
        return 'Rejected';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  static Color foreground(String status) {
    switch (status) {
      case OrderStatuses.pending:
        return AdminColors.warn;
      case OrderStatuses.accepted:
      case OrderStatuses.processing:
        return const Color(0xFF4B5E7A);
      case OrderStatuses.dispatched:
      case OrderStatuses.outForDelivery:
        return AdminColors.brassDark;
      case OrderStatuses.delivered:
        return AdminColors.success;
      case OrderStatuses.cancelled:
      case OrderStatuses.rejected:
        return AdminColors.danger;
      default:
        return AdminColors.muted;
    }
  }

  static Color background(String status) {
    switch (status) {
      case OrderStatuses.pending:
        return AdminColors.warnTint;
      case OrderStatuses.accepted:
      case OrderStatuses.processing:
        return const Color(0xFFEAEFF6);
      case OrderStatuses.dispatched:
      case OrderStatuses.outForDelivery:
        return AdminColors.brassTint;
      case OrderStatuses.delivered:
        return AdminColors.successTint;
      case OrderStatuses.cancelled:
      case OrderStatuses.rejected:
        return AdminColors.dangerTint;
      default:
        return const Color(0xFFEFEDF3);
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case OrderStatuses.pending:
        return Icons.schedule_rounded;
      case OrderStatuses.accepted:
        return Icons.check_circle_outline_rounded;
      case OrderStatuses.processing:
        return Icons.inventory_2_outlined;
      case OrderStatuses.dispatched:
        return Icons.local_shipping_outlined;
      case OrderStatuses.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatuses.delivered:
        return Icons.task_alt_rounded;
      case OrderStatuses.cancelled:
      case OrderStatuses.rejected:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static AdminBadge badge(String status) => AdminBadge(
    label: label(status),
    foreground: foreground(status),
    background: background(status),
  );
}

/// Payment status shares the same pill treatment.
class PaymentStatusStyle {
  PaymentStatusStyle._();

  static String label(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Unpaid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  static AdminBadge badge(String status) {
    switch (status) {
      case 'paid':
        return const AdminBadge(
          label: 'Paid',
          foreground: AdminColors.success,
          background: AdminColors.successTint,
        );
      case 'failed':
        return const AdminBadge(
          label: 'Failed',
          foreground: AdminColors.danger,
          background: AdminColors.dangerTint,
        );
      case 'refunded':
        return const AdminBadge(
          label: 'Refunded',
          foreground: Color(0xFF4B5E7A),
          background: Color(0xFFEAEFF6),
        );
      default:
        return const AdminBadge(
          label: 'Unpaid',
          foreground: AdminColors.warn,
          background: AdminColors.warnTint,
        );
    }
  }
}
