import 'package:flutter/material.dart';

import '../models/return_request_model.dart';
import '../theme/admin_theme.dart';
import 'admin_badge.dart';

/// Same pill treatment [OrderStatusStyle] and [ComplaintStatusStyle] use,
/// applied to return request statuses.
class ReturnStatusStyle {
  ReturnStatusStyle._();

  static String label(String status) {
    switch (status) {
      case ReturnStatuses.pending:
        return 'Pending';
      case ReturnStatuses.approved:
        return 'Approved';
      case ReturnStatuses.rejected:
        return 'Rejected';
      case ReturnStatuses.completed:
        return 'Completed';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  static Color foreground(String status) {
    switch (status) {
      case ReturnStatuses.pending:
        return AdminColors.warn;
      case ReturnStatuses.approved:
        return const Color(0xFF2563EB);
      case ReturnStatuses.rejected:
        return AdminColors.danger;
      case ReturnStatuses.completed:
        return AdminColors.success;
      default:
        return AdminColors.muted;
    }
  }

  static Color background(String status) {
    switch (status) {
      case ReturnStatuses.pending:
        return AdminColors.warnTint;
      case ReturnStatuses.approved:
        return const Color(0xFFEAEFF6);
      case ReturnStatuses.rejected:
        return AdminColors.dangerTint;
      case ReturnStatuses.completed:
        return AdminColors.successTint;
      default:
        return const Color(0xFFEFEDF3);
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case ReturnStatuses.pending:
        return Icons.hourglass_top_rounded;
      case ReturnStatuses.approved:
        return Icons.thumb_up_alt_outlined;
      case ReturnStatuses.rejected:
        return Icons.block_rounded;
      case ReturnStatuses.completed:
        return Icons.check_circle_outline_rounded;
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
