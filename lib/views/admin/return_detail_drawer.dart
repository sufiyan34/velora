import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controllers/admin_returns_controller.dart';
import 'package:e_commerce/models/return_request_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/admin_skeleton.dart';
import 'package:e_commerce/utills/right_drawer.dart';
import 'package:e_commerce/utills/return_status_style.dart';
import 'package:e_commerce/views/admin/order_detail_drawer.dart'
    show AdminSectionCardLite;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

/// Opens the return request detail/review drawer for [returnId].
Future<void> showReturnDetailDrawer({
  required BuildContext context,
  required String returnId,
  required AdminReturnsController controller,
}) {
  return showRightDrawer(
    context: context,
    maxWidth: 520,
    builder: (context) =>
        ReturnDetailDrawer(returnId: returnId, controller: controller),
  );
}

class ReturnDetailDrawer extends StatefulWidget {
  const ReturnDetailDrawer({
    super.key,
    required this.returnId,
    required this.controller,
  });

  final String returnId;
  final AdminReturnsController controller;

  @override
  State<ReturnDetailDrawer> createState() => _ReturnDetailDrawerState();
}

class _ReturnDetailDrawerState extends State<ReturnDetailDrawer> {
  late final TextEditingController _noteController;
  bool _noteDirty = false;

  @override
  void initState() {
    super.initState();
    final request = widget.controller.byId(widget.returnId);
    _noteController = TextEditingController(text: request?.adminNote ?? '');
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
        final request = widget.controller.byId(widget.returnId);
        final busy = widget.controller.busyReturnId.value == widget.returnId;

        if (request == null) {
          return Column(
            children: [
              _DrawerTopBar(title: 'Return request', onClose: () => Get.back()),
              const Expanded(child: AdminDetailSkeleton()),
            ],
          );
        }

        return Column(
          children: [
            _DrawerTopBar(
              title: AdminFormat.orderRef(request.orderId),
              subtitle: AdminFormat.dateTimeShort(request.createdAt),
              onClose: () => Get.back(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _StatusHero(request: request),
                  const SizedBox(height: 18),
                  _DetailsCard(request: request),
                  const SizedBox(height: 18),
                  _ItemsCard(request: request),
                  if (request.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _PhotosCard(request: request),
                  ],
                  const SizedBox(height: 18),
                  _NoteCard(
                    controller: _noteController,
                    dirty: _noteDirty,
                    busy: busy,
                    onChanged: () => setState(() => _noteDirty = true),
                    onSend: () async {
                      final ok = await widget.controller.setStatus(
                        request.id,
                        request.status,
                        adminNote: _noteController.text,
                      );
                      if (ok) setState(() => _noteDirty = false);
                    },
                  ),
                ],
              ),
            ),
            _ActionBar(
              request: request,
              busy: busy,
              controller: widget.controller,
            ),
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminText.display(19),
                ),
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
  const _StatusHero({required this.request});

  final ReturnRequestModel request;

  @override
  Widget build(BuildContext context) {
    final color = ReturnStatusStyle.foreground(request.status);
    final bg = ReturnStatusStyle.background(request.status);

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
              ReturnStatusStyle.icon(request.status),
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
                  ReturnStatusStyle.label(request.status),
                  style: AdminText.display(17, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_resolutionLabel(request.resolution)} requested',
                  style: AdminText.body(12.5, color: AdminColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 260));
  }

  String _resolutionLabel(String resolution) {
    switch (resolution) {
      case 'exchange':
        return 'Exchange';
      case 'store_credit':
        return 'Store credit';
      default:
        return 'Refund';
    }
  }
}

// ===========================================================================
// DETAILS
// ===========================================================================

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.request});

  final ReturnRequestModel request;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'Order',
                  value: AdminFormat.orderRef(request.orderId),
                  trailing: request.orderId.isEmpty
                      ? null
                      : _IconChip(
                          onTap: () => Clipboard.setData(
                            ClipboardData(text: request.orderId),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: _MetaTile(
                  label: 'Customer ID',
                  value: request.userId.isEmpty
                      ? '—'
                      : '${request.userId.substring(0, request.userId.length.clamp(0, 8))}…',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AdminColors.line),
          const SizedBox(height: 14),
          Text(
            'Reason',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.reason,
            style: AdminText.body(13, weight: FontWeight.w600),
          ),
          if (request.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.description,
              style: AdminText.body(13, color: AdminColors.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AdminText.body(11.5, color: AdminColors.muted)),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AdminText.body(13.5, weight: FontWeight.w600),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
      ],
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copy order ID',
      child: Material(
        color: AdminColors.brassTint,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.copy_rounded,
              size: 13,
              color: AdminColors.brassDark,
            ),
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
  const _ItemsCard({required this.request});

  final ReturnRequestModel request;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items to return',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in request.items) ...[
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
                        if (item.variationDisplayName != null)
                          Text(
                            item.variationDisplayName!,
                            style: AdminText.body(
                              11.5,
                              color: AdminColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.returnQuantity} × ${AdminFormat.money(item.price)}',
                    style: AdminText.body(12, color: AdminColors.muted),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1, color: AdminColors.line),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated refund',
                style: AdminText.body(13.5, weight: FontWeight.w700),
              ),
              Text(
                AdminFormat.money(request.estimatedRefund),
                style: AdminText.body(15, weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PHOTOS
// ===========================================================================

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({required this.request});

  final ReturnRequestModel request;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer photos',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final url in request.photoUrls)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AdminColors.canvas,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AdminColors.muted,
                        size: 18,
                      ),
                    ),
                    placeholder: (_, __) => AdminSkeleton.shimmer(
                      child: AdminSkeleton.block(
                        width: 72,
                        height: 72,
                        radius: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// NOTE TO CUSTOMER
// ===========================================================================

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.controller,
    required this.dirty,
    required this.busy,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool dirty;
  final bool busy;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note to customer',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shown to the customer on their return history — explain an approval or rejection.',
            style: AdminText.body(11.5, color: AdminColors.muted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            maxLines: 4,
            style: AdminText.body(13),
            decoration: InputDecoration(
              hintText: 'e.g. "Refund issued to your original payment method"',
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
                onPressed: onSend,
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
    required this.request,
    required this.busy,
    required this.controller,
  });

  final ReturnRequestModel request;
  final bool busy;
  final AdminReturnsController controller;

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
        child: _StatusMenuButton(
          request: request,
          busy: busy,
          controller: controller,
        ),
      ),
    );
  }
}

class _StatusMenuButton extends StatelessWidget {
  const _StatusMenuButton({
    required this.request,
    required this.busy,
    required this.controller,
  });

  final ReturnRequestModel request;
  final bool busy;
  final AdminReturnsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PopupMenuButton<String>(
        enabled: !busy,
        tooltip: 'Change status',
        offset: const Offset(0, -180),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          for (final status in ReturnStatuses.all)
            if (status != request.status)
              PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      ReturnStatusStyle.icon(status),
                      size: 16,
                      color: ReturnStatusStyle.foreground(status),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ReturnStatusStyle.label(status),
                      style: AdminText.body(13),
                    ),
                  ],
                ),
              ),
        ],
        onSelected: (status) => controller.setStatus(request.id, status),
        child: IgnorePointer(
          child: AdminPrimaryButton(
            label: 'Update status',
            icon: Icons.sync_alt_rounded,
            loading: busy,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
