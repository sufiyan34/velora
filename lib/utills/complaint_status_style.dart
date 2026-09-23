import 'package:flutter/material.dart';

import '../theme/admin_theme.dart';
import 'admin_badge.dart';
import '../models/complaint_model.dart';

/// Same pill treatment [OrderStatusStyle] uses for orders, applied to
/// complaint statuses.
class ComplaintStatusStyle {
  ComplaintStatusStyle._();

  static String label(String status) {
    switch (status) {
      case ComplaintStatuses.open:
        return 'Open';
      case ComplaintStatuses.inProgress:
        return 'In progress';
      case ComplaintStatuses.resolved:
        return 'Resolved';
      case ComplaintStatuses.closed:
        return 'Closed';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  static Color foreground(String status) {
    switch (status) {
      case ComplaintStatuses.open:
        return AdminColors.warn;
      case ComplaintStatuses.inProgress:
        return const Color(0xFF4B5E7A);
      case ComplaintStatuses.resolved:
        return AdminColors.success;
      case ComplaintStatuses.closed:
        return AdminColors.muted;
      default:
        return AdminColors.muted;
    }
  }

  static Color background(String status) {
    switch (status) {
      case ComplaintStatuses.open:
        return AdminColors.warnTint;
      case ComplaintStatuses.inProgress:
        return const Color(0xFFEAEFF6);
      case ComplaintStatuses.resolved:
        return AdminColors.successTint;
      case ComplaintStatuses.closed:
        return const Color(0xFFEFEDF3);
      default:
        return const Color(0xFFEFEDF3);
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case ComplaintStatuses.open:
        return Icons.error_outline_rounded;
      case ComplaintStatuses.inProgress:
        return Icons.hourglass_top_rounded;
      case ComplaintStatuses.resolved:
        return Icons.check_circle_outline_rounded;
      case ComplaintStatuses.closed:
        return Icons.lock_outline_rounded;
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
