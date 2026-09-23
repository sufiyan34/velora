import 'package:e_commerce/models/complaint_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/complaint_status_style.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';

class ComplaintRow extends StatelessWidget {
  const ComplaintRow({super.key, required this.complaint, required this.onTap});

  final ComplaintModel complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? _MobileCard(complaint: complaint, onTap: onTap)
        : _DesktopRow(complaint: complaint, onTap: onTap);
  }
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({required this.complaint, required this.onTap});

  final ComplaintModel complaint;
  final VoidCallback onTap;

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
                  AdminSwatch(seed: complaint.subject),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          complaint.subject,
                          overflow: TextOverflow.ellipsis,
                          style: AdminText.body(13.5, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          complaint.hasOrder
                              ? AdminFormat.orderRef(complaint.orderId!)
                              : 'Not linked to an order',
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
              child: Text(complaint.category, style: AdminText.body(13)),
            ),
            Expanded(
              flex: 2,
              child: complaint.hasResponse
                  ? const AdminBadge(
                      label: 'Responded',
                      foreground: AdminColors.success,
                      background: AdminColors.successTint,
                    )
                  : const AdminBadge(
                      label: 'Awaiting reply',
                      foreground: AdminColors.muted,
                      background: Color(0xFFEFEDF3),
                    ),
            ),
            Expanded(
              flex: 2,
              child: ComplaintStatusStyle.badge(complaint.status),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AdminFormat.relative(complaint.createdAt),
                style: AdminText.body(12, color: AdminColors.muted),
              ),
            ),
            const SizedBox(
              width: 30,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AdminColors.muted,
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
  const _MobileCard({required this.complaint, required this.onTap});

  final ComplaintModel complaint;
  final VoidCallback onTap;

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
                AdminSwatch(seed: complaint.subject, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        complaint.subject,
                        overflow: TextOverflow.ellipsis,
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        complaint.category,
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
                ComplaintStatusStyle.badge(complaint.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AdminColors.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  complaint.hasOrder
                      ? AdminFormat.orderRef(complaint.orderId!)
                      : 'No linked order',
                  style: AdminText.body(12, color: AdminColors.muted),
                ),
                const Spacer(),
                Text(
                  AdminFormat.relative(complaint.createdAt),
                  style: AdminText.body(12, color: AdminColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
