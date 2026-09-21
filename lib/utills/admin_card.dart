import 'package:flutter/material.dart';

import '../theme/admin_theme.dart';

/// White panel with a heading row — the container every dashboard block,
/// table and form section sits in.
class AdminSectionCard extends StatelessWidget {
  const AdminSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.line),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: AdminText.display(16)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AdminText.body(12.5, color: AdminColors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// A single KPI tile: label, big number, optional trend against the previous
/// period and an optional footnote line.
class AdminStatCard extends StatefulWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AdminColors.brass,
    this.tint = AdminColors.brassTint,
    this.delta,
    this.deltaSuffix = 'vs previous period',
    this.footnote,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color tint;

  /// Percentage change. Null hides the trend row.
  final double? delta;
  final String deltaSuffix;
  final String? footnote;
  final VoidCallback? onTap;

  @override
  State<AdminStatCard> createState() => _AdminStatCardState();
}

class _AdminStatCardState extends State<AdminStatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final delta = widget.delta;
    final bool up = (delta ?? 0) >= 0;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hover
                  ? widget.accent.withValues(alpha: 0.45)
                  : AdminColors.line,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: AdminColors.ink.withValues(alpha: 0.07),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, size: 18, color: widget.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AdminText.body(12.5, color: AdminColors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(widget.value, style: AdminText.display(24)),
              ),
              if (delta != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      up
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 15,
                      color: up ? AdminColors.success : AdminColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${up ? '+' : ''}${delta.toStringAsFixed(1)}%',
                      style: AdminText.body(
                        12,
                        weight: FontWeight.w600,
                        color: up ? AdminColors.success : AdminColors.danger,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.deltaSuffix,
                        overflow: TextOverflow.ellipsis,
                        style: AdminText.body(11.5, color: AdminColors.muted),
                      ),
                    ),
                  ],
                ),
              ] else if (widget.footnote != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.footnote!,
                  style: AdminText.body(11.5, color: AdminColors.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact action button used in the dashboard's quick-actions row.
class AdminQuickAction extends StatelessWidget {
  const AdminQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        hoverColor: AdminColors.brassTint,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AdminColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AdminColors.brassDark),
              const SizedBox(width: 8),
              Text(label, style: AdminText.body(13, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small centred placeholder for empty panels.
class AdminEmptyHint extends StatelessWidget {
  const AdminEmptyHint({
    super.key,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.height = 140,
  });

  final String message;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFC7C2D6)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AdminText.body(13, color: AdminColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
