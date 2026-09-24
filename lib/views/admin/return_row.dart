import 'package:e_commerce/models/return_request_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/utills/return_status_style.dart';
import 'package:flutter/material.dart';

class ReturnRow extends StatelessWidget {
  const ReturnRow({super.key, required this.request, required this.onTap});

  final ReturnRequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context)
        ? _MobileCard(request: request, onTap: onTap)
        : _DesktopRow(request: request, onTap: onTap);
  }
}

String _itemsSummary(ReturnRequestModel request) {
  if (request.items.isEmpty) return 'No items';
  final first = request.items.first.productName;
  final extra = request.items.length - 1;
  return extra > 0 ? '$first +$extra more' : first;
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({required this.request, required this.onTap});

  final ReturnRequestModel request;
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
                  AdminSwatch(
                    seed: request.orderId.isEmpty
                        ? request.id
                        : request.orderId,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AdminFormat.orderRef(request.orderId),
                          style: AdminText.body(13.5, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _itemsSummary(request),
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
              child: Text(request.reason, style: AdminText.body(13)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AdminFormat.money(request.estimatedRefund),
                style: AdminText.body(13.5, weight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 2, child: ReturnStatusStyle.badge(request.status)),
            Expanded(
              flex: 2,
              child: Text(
                AdminFormat.relative(request.createdAt),
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
  const _MobileCard({required this.request, required this.onTap});

  final ReturnRequestModel request;
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
                AdminSwatch(
                  seed: request.orderId.isEmpty ? request.id : request.orderId,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AdminFormat.orderRef(request.orderId),
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _itemsSummary(request),
                        overflow: TextOverflow.ellipsis,
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
                ReturnStatusStyle.badge(request.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AdminColors.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  AdminFormat.money(request.estimatedRefund),
                  style: AdminText.body(12.5, weight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  AdminFormat.relative(request.createdAt),
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
