import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

class AdminPrimaryButton extends StatelessWidget {
  const AdminPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.brass,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AdminColors.brass.withValues(alpha: 0.6),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 7),
                ],
                Text(label,
                    style: AdminText.body(13.5, weight: FontWeight.w600, color: Colors.white)),
              ],
            ),
    );
  }
}

class AdminGhostButton extends StatelessWidget {
  const AdminGhostButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.ink,
        side: const BorderSide(color: AdminColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      onPressed: onPressed,
      child: Text(label, style: AdminText.body(13.5, weight: FontWeight.w600)),
    );
  }
}

class AdminIconButton extends StatelessWidget {
  const AdminIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.danger = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AdminColors.surface,
          border: Border.all(color: AdminColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: danger ? AdminColors.danger : AdminColors.inkSoft),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
