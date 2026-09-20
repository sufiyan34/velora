import 'package:e_commerce/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown when a signed-in user lands on a route their role can't open.
///
/// ```dart
/// GetPage(
///   name: '/admin/products',
///   page: () => const ProductsScreen(),
///   middlewares: [RoleGuard(permission: 'products.manage')],
/// );
/// ```
class AccessDeniedScreen extends StatelessWidget {
  /// The permission the route asked for, e.g. `orders.refund`.
  final String? requiredPermission;

  /// Where the primary button goes. Ignored if [onHome] is supplied.
  final String homeRoute;

  final VoidCallback? onHome;
  final VoidCallback? onBack;

  /// Shows a third, quieter action when supplied (email the admin,
  /// open a request form, fire a Firestore access request, …).
  final VoidCallback? onRequestAccess;

  const AccessDeniedScreen({
    super.key,
    this.requiredPermission,
    this.homeRoute = '/dashboard',
    this.onHome,
    this.onBack,
    this.onRequestAccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: VeloraColors.pageGradient),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -80,
              child: _DriftBlob(color: VeloraColors.primary, size: 320),
            ),
            const Positioned(
              bottom: -140,
              right: -90,
              child: _DriftBlob(
                color: VeloraColors.rose,
                size: 300,
                reverse: true,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 560;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 18 : 32,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _DeniedCard(
                        compact: compact,
                        requiredPermission: requiredPermission,
                        onHome: onHome ?? () => Get.offAllNamed(homeRoute),
                        onBack: onBack ?? () => Get.back(),
                        onRequestAccess: onRequestAccess,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DeniedCard extends StatelessWidget {
  final bool compact;
  final String? requiredPermission;
  final VoidCallback onHome;
  final VoidCallback onBack;
  final VoidCallback? onRequestAccess;

  const _DeniedCard({
    required this.compact,
    required this.requiredPermission,
    required this.onHome,
    required this.onBack,
    this.onRequestAccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 22 : 36,
        vertical: compact ? 30 : 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: VeloraColors.ink900.withValues(alpha: 0.10),
            blurRadius: 48,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LockMark(compact: compact),
          SizedBox(height: compact ? 26 : 32),
          Text(
                'You don\'t have access to this page',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: compact ? 23 : 28,
                  height: 1.2,
                  color: VeloraColors.ink900,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 500))
              .slideY(begin: 0.18, curve: Curves.easeOutCubic),
          const SizedBox(height: 12),
          Text(
                'Your account role doesn\'t include this area of the Velora '
                'dashboard. An admin can grant it from Settings → Team.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  height: 1.6,
                  color: VeloraColors.ink500,
                  fontWeight: FontWeight.w500,
                ),
              )
              .animate(delay: const Duration(milliseconds: 120))
              .fadeIn(duration: const Duration(milliseconds: 500))
              .slideY(begin: 0.18, curve: Curves.easeOutCubic),
          if (requiredPermission != null) ...[
            SizedBox(height: compact ? 22 : 28),
            _PermissionChip(permission: requiredPermission!)
                .animate(delay: const Duration(milliseconds: 260))
                .fadeIn(duration: const Duration(milliseconds: 450))
                .scaleXY(begin: 0.94, end: 1, curve: Curves.easeOutBack),
          ],
          SizedBox(height: compact ? 28 : 36),
          _ActionButton(
                label: 'Go to dashboard',
                icon: Icons.grid_view_rounded,
                filled: true,
                onPressed: onHome,
              )
              .animate(delay: const Duration(milliseconds: 340))
              .fadeIn(duration: const Duration(milliseconds: 420))
              .slideY(begin: 0.25, curve: Curves.easeOutCubic),
          const SizedBox(height: 12),
          _ActionButton(
                label: 'Go back',
                icon: Icons.arrow_back_rounded,
                filled: false,
                onPressed: onBack,
              )
              .animate(delay: const Duration(milliseconds: 420))
              .fadeIn(duration: const Duration(milliseconds: 420))
              .slideY(begin: 0.25, curve: Curves.easeOutCubic),
          if (onRequestAccess != null) ...[
            const SizedBox(height: 6),
            TextButton(
                  onPressed: onRequestAccess,
                  style: TextButton.styleFrom(
                    foregroundColor: VeloraColors.primary,
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Ask an admin for access'),
                )
                .animate(delay: const Duration(milliseconds: 500))
                .fadeIn(duration: const Duration(milliseconds: 420)),
          ],
        ],
      ),
    );
  }
}

/// Padlock inside a pair of outward-travelling rings.
class _LockMark extends StatelessWidget {
  final bool compact;

  const _LockMark({required this.compact});

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 104 : 124;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _Ring(size: size, delay: Duration.zero),
          _Ring(size: size, delay: const Duration(milliseconds: 900)),
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: VeloraColors.rose.withValues(alpha: 0.22),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.lock_rounded,
              size: size * 0.32,
              color: VeloraColors.rose,
            ),
          ).animate().scaleXY(
            begin: 0.7,
            end: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Duration delay;

  const _Ring({required this.size, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VeloraColors.rose.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(), delay: delay)
        .scaleXY(
          begin: 0.9,
          end: 1.45,
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOut,
        )
        .fadeOut(duration: const Duration(milliseconds: 1800));
  }
}

class _PermissionChip extends StatelessWidget {
  final String permission;

  const _PermissionChip({required this.permission});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VeloraColors.rose.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.key_rounded,
            size: 18,
            color: VeloraColors.rose.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Missing permission',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: VeloraColors.ink500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  permission,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: VeloraColors.rose,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width button that lifts slightly under the pointer.
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.filled;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: _hover ? 1.02 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: filled ? VeloraColors.brandGradient : null,
            color: filled ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: filled
                ? null
                : Border.all(
                    color: _hover
                        ? VeloraColors.primary.withValues(alpha: 0.5)
                        : VeloraColors.ink200,
                    width: 1.5,
                  ),
            boxShadow: filled
                ? VeloraColors.glow(
                    VeloraColors.primary,
                    opacity: _hover ? 0.5 : 0.32,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 19,
                      color: filled ? Colors.white : VeloraColors.ink900,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: filled ? Colors.white : VeloraColors.ink900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft out-of-focus colour wash drifting behind the card.
class _DriftBlob extends StatelessWidget {
  final Color color;
  final double size;
  final bool reverse;

  const _DriftBlob({
    required this.color,
    required this.size,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: reverse ? -50 : 50,
                duration: const Duration(milliseconds: 9000),
                curve: Curves.easeInOut,
              ),
    );
  }
}
