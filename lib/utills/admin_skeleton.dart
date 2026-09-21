import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/admin_theme.dart';
import 'responsive.dart';

/// Shimmer wrapper + building blocks shared by every admin screen's loading
/// state, so a table, a card grid and a KPI strip all shimmer the same way.
class AdminSkeleton {
  AdminSkeleton._();

  static Widget shimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: AdminColors.line.withValues(alpha: 0.7),
      highlightColor: AdminColors.canvas,
      period: const Duration(milliseconds: 1300),
      child: child,
    );
  }

  static Widget block({
    double width = double.infinity,
    double height = 14,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// One shimmering KPI tile — same footprint as [AdminStatCard].
class AdminStatCardSkeleton extends StatelessWidget {
  const AdminStatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton.shimmer(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AdminSkeleton.block(width: 36, height: 36, radius: 10),
                const SizedBox(width: 10),
                Expanded(child: AdminSkeleton.block(height: 12)),
              ],
            ),
            const SizedBox(height: 16),
            AdminSkeleton.block(width: 90, height: 22),
            const SizedBox(height: 10),
            AdminSkeleton.block(width: 130, height: 11),
          ],
        ),
      ),
    );
  }
}

/// A row that mimics a table/list row: leading swatch, two text lines, and a
/// couple of trailing columns. Used by Orders, Dispatch, Customers, Payments.
class AdminRowSkeleton extends StatelessWidget {
  const AdminRowSkeleton({
    super.key,
    this.trailingColumns = 2,
    this.showLeadingImage = true,
  });

  final int trailingColumns;
  final bool showLeadingImage;

  @override
  Widget build(BuildContext context) {
    final bool compact = Responsive.isMobile(context);

    return AdminSkeleton.shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            if (showLeadingImage) ...[
              AdminSkeleton.block(width: 38, height: 38, radius: 10),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdminSkeleton.block(width: 140, height: 13),
                  const SizedBox(height: 8),
                  AdminSkeleton.block(width: 90, height: 11),
                ],
              ),
            ),
            if (!compact)
              for (int i = 0; i < trailingColumns; i++) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: AdminSkeleton.block(width: 70, height: 22, radius: 20),
                ),
              ],
            const SizedBox(width: 16),
            AdminSkeleton.block(width: 60, height: 13),
          ],
        ),
      ),
    );
  }
}

/// A whole panel of skeleton rows, wrapped in the same card chrome the real
/// list uses — so the loading state and the loaded state don't visibly jump.
class AdminListSkeleton extends StatelessWidget {
  const AdminListSkeleton({
    super.key,
    this.rows = 6,
    this.trailingColumns = 2,
    this.showLeadingImage = true,
  });

  final int rows;
  final int trailingColumns;
  final bool showLeadingImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < rows; i++) ...[
            AdminRowSkeleton(
              trailingColumns: trailingColumns,
              showLeadingImage: showLeadingImage,
            ),
            if (i != rows - 1)
              const Divider(height: 1, color: AdminColors.line),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for a stacked mobile card (used when a table row is too tight).
class AdminCardSkeleton extends StatelessWidget {
  const AdminCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton.shimmer(
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
                AdminSkeleton.block(width: 40, height: 40, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminSkeleton.block(width: 120, height: 13),
                      const SizedBox(height: 8),
                      AdminSkeleton.block(width: 80, height: 11),
                    ],
                  ),
                ),
                AdminSkeleton.block(width: 60, height: 20, radius: 20),
              ],
            ),
            const SizedBox(height: 14),
            AdminSkeleton.block(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                AdminSkeleton.block(width: 70, height: 11),
                const Spacer(),
                AdminSkeleton.block(width: 50, height: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed-height block for drawers/detail panels while a single record loads.
class AdminDetailSkeleton extends StatelessWidget {
  const AdminDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSkeleton.shimmer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AdminSkeleton.block(width: 160, height: 20),
          const SizedBox(height: 8),
          AdminSkeleton.block(width: 100, height: 12),
          const SizedBox(height: 24),
          AdminSkeleton.block(height: 90, radius: 14),
          const SizedBox(height: 16),
          AdminSkeleton.block(height: 140, radius: 14),
          const SizedBox(height: 16),
          AdminSkeleton.block(height: 100, radius: 14),
        ],
      ),
    );
  }
}
