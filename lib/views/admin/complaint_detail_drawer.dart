import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controllers/admin_complaints_controller.dart';
import 'package:e_commerce/models/complaint_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_format.dart';
import 'package:e_commerce/utills/admin_skeleton.dart';
import 'package:e_commerce/utills/complaint_status_style.dart';
import 'package:e_commerce/utills/right_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

/// Opens the complaint detail/review drawer for [complaintId].
Future<void> showComplaintDetailDrawer({
  required BuildContext context,
  required String complaintId,
  required AdminComplaintsController controller,
}) {
  return showRightDrawer(
    context: context,
    maxWidth: 520,
    builder: (context) =>
        ComplaintDetailDrawer(complaintId: complaintId, controller: controller),
  );
}

class ComplaintDetailDrawer extends StatefulWidget {
  const ComplaintDetailDrawer({
    super.key,
    required this.complaintId,
    required this.controller,
  });

  final String complaintId;
  final AdminComplaintsController controller;

  @override
  State<ComplaintDetailDrawer> createState() => _ComplaintDetailDrawerState();
}

class _ComplaintDetailDrawerState extends State<ComplaintDetailDrawer> {
  late final TextEditingController _responseController;
  bool _responseDirty = false;

  @override
  void initState() {
    super.initState();
    final complaint = widget.controller.byId(widget.complaintId);
    _responseController = TextEditingController(
      text: complaint?.adminResponse ?? '',
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.canvas,
      child: Obx(() {
        final complaint = widget.controller.byId(widget.complaintId);
        final busy =
            widget.controller.busyComplaintId.value == widget.complaintId;

        if (complaint == null) {
          return Column(
            children: [
              _DrawerTopBar(title: 'Complaint', onClose: () => Get.back()),
              const Expanded(child: AdminDetailSkeleton()),
            ],
          );
        }

        return Column(
          children: [
            _DrawerTopBar(
              title: complaint.subject,
              subtitle: AdminFormat.dateTimeShort(complaint.createdAt),
              onClose: () => Get.back(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _StatusHero(complaint: complaint),
                  const SizedBox(height: 18),
                  _DetailsCard(complaint: complaint),
                  if (complaint.hasPhotos) ...[
                    const SizedBox(height: 18),
                    _PhotosCard(complaint: complaint),
                  ],
                  const SizedBox(height: 18),
                  _ResponseCard(
                    controller: _responseController,
                    dirty: _responseDirty,
                    busy: busy,
                    onChanged: () => setState(() => _responseDirty = true),
                    onSend: () async {
                      final ok = await widget.controller.respond(
                        complaint.id,
                        _responseController.text,
                        status: complaint.status == ComplaintStatuses.open
                            ? ComplaintStatuses.inProgress
                            : null,
                      );
                      if (ok) setState(() => _responseDirty = false);
                    },
                  ),
                ],
              ),
            ),
            _ActionBar(
              complaint: complaint,
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
  const _StatusHero({required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final color = ComplaintStatusStyle.foreground(complaint.status);
    final bg = ComplaintStatusStyle.background(complaint.status);

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
              ComplaintStatusStyle.icon(complaint.status),
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
                  ComplaintStatusStyle.label(complaint.status),
                  style: AdminText.display(17, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  complaint.category,
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

/// A section card without the title row.
class _SectionCardLite extends StatelessWidget {
  const _SectionCardLite({required this.child});

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
// DETAILS
// ===========================================================================

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    return _SectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'Related order',
                  value: complaint.hasOrder
                      ? AdminFormat.orderRef(complaint.orderId!)
                      : 'None',
                  trailing: complaint.hasOrder
                      ? _IconChip(
                          icon: Icons.copy_rounded,
                          tooltip: 'Copy order ID',
                          onTap: () => Clipboard.setData(
                            ClipboardData(text: complaint.orderId!),
                          ),
                        )
                      : null,
                ),
              ),
              Expanded(
                child: _MetaTile(
                  label: 'Customer ID',
                  value: complaint.userId.isEmpty
                      ? '—'
                      : '${complaint.userId.substring(0, complaint.userId.length.clamp(0, 8))}…',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AdminColors.line),
          const SizedBox(height: 14),
          Text(
            'Description',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            complaint.description.isEmpty
                ? 'No description provided.'
                : complaint.description,
            style: AdminText.body(
              13,
              color: AdminColors.inkSoft,
              weight: FontWeight.w500,
            ),
          ),
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
// PHOTOS
// ===========================================================================

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    return _SectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos',
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
              for (final url in complaint.photoUrls)
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
// RESPONSE
// ===========================================================================

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({
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
    return _SectionCardLite(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response to customer',
            style: AdminText.body(
              12.5,
              weight: FontWeight.w700,
              color: AdminColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shown to the customer on their complaint history.',
            style: AdminText.body(11.5, color: AdminColors.muted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            maxLines: 4,
            style: AdminText.body(13),
            decoration: InputDecoration(
              hintText: 'Write a reply the customer will see…',
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
                label: 'Send response',
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
    required this.complaint,
    required this.busy,
    required this.controller,
  });

  final ComplaintModel complaint;
  final bool busy;
  final AdminComplaintsController controller;

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
          complaint: complaint,
          busy: busy,
          controller: controller,
        ),
      ),
    );
  }
}

class _StatusMenuButton extends StatelessWidget {
  const _StatusMenuButton({
    required this.complaint,
    required this.busy,
    required this.controller,
  });

  final ComplaintModel complaint;
  final bool busy;
  final AdminComplaintsController controller;

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
          for (final status in ComplaintStatuses.all)
            if (status != complaint.status)
              PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      ComplaintStatusStyle.icon(status),
                      size: 16,
                      color: ComplaintStatusStyle.foreground(status),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ComplaintStatusStyle.label(status),
                      style: AdminText.body(13),
                    ),
                  ],
                ),
              ),
        ],
        onSelected: (status) => controller.setStatus(complaint.id, status),
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
