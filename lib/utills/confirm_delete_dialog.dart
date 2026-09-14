import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

/// Shows a delete confirmation and resolves `true` only if the admin
/// confirms. [warning], when provided, renders as a soft amber notice below
/// the main message — used when a category still has subcategories or
/// tagged products.
Future<bool> confirmDelete({
  required BuildContext context,
  required String title,
  required String message,
  String? warning,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AdminColors.dangerTint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AdminColors.danger, size: 22),
                ),
                const SizedBox(height: 14),
                Text(title, style: AdminText.display(19)),
                const SizedBox(height: 8),
                Text(message, style: AdminText.body(13.5, color: AdminColors.muted)),
                if (warning != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AdminColors.warnTint,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      warning,
                      style: AdminText.body(12.5, color: AdminColors.warn),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel',
                          style: AdminText.body(13.5, weight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete',
                          style: AdminText.body(13.5, weight: FontWeight.w600, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
