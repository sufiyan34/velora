import 'package:e_commerce/constants/app_colors.dart';
import 'package:e_commerce/controllers/velora_sidebar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// One row in the sidebar.
///
/// Set [section] to start a new labelled group — the first item carrying a
/// given section string renders the group heading above itself.
class VeloraSidebarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  /// Small counter chip, e.g. pending orders. Shows as a dot on the rail.
  final String? badge;
  final Color? badgeColor;

  final VoidCallback? onTap;
  final bool isActive;
  final String? section;

  const VeloraSidebarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    this.onTap,
    this.isActive = false,
    this.section,
  });
}

/// The sidebar panel itself. Usually you want [VeloraNavShell], which places
/// this correctly for each breakpoint and adds the mobile top bar.
class VeloraSidebar extends StatelessWidget {
  final List<VeloraSidebarItem> items;
  final VeloraSidebarController? controller;

  /// Rendered above the nav list. Receives the current expanded state so it
  /// can shrink to an icon on the rail. Defaults to the Velora wordmark.
  final Widget Function(BuildContext context, bool expanded)? headerBuilder;

  /// Rendered under the nav list, above the collapse control.
  final Widget Function(BuildContext context, bool expanded)? footerBuilder;

  final double extendedWidth;
  final double compactWidth;
  final Duration duration;

  const VeloraSidebar({
    super.key,
    required this.items,
    this.controller,
    this.headerBuilder,
    this.footerBuilder,
    this.extendedWidth = 268,
    this.compactWidth = 84,
    this.duration = const Duration(milliseconds: 260),
  });

  @override
  Widget build(BuildContext context) {
    final c = controller ?? VeloraSidebarController.instance;
    c.ensureInitialSelection(items.indexWhere((i) => i.isActive));

    return Obx(() {
      final bool expanded = c.expanded;
      final bool mobile = c.isMobile;
      final double width = mobile
          ? extendedWidth
          : (expanded ? extendedWidth : compactWidth);

      return RepaintBoundary(
        child: MouseRegion(
          onEnter: (_) => c.onPanelEnter(),
          onExit: (_) => c.onPanelExit(),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            width: width,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              // The panel is always laid out at full width and clipped, so
              // labels never overflow while the rail animates closed.
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: extendedWidth,
                maxWidth: extendedWidth,
                child: _SidebarPanel(
                  items: items,
                  controller: c,
                  expanded: expanded,
                  mobile: mobile,
                  duration: duration,
                  headerBuilder: headerBuilder,
                  footerBuilder: footerBuilder,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SidebarPanel extends StatelessWidget {
  final List<VeloraSidebarItem> items;
  final VeloraSidebarController controller;
  final bool expanded;
  final bool mobile;
  final Duration duration;
  final Widget Function(BuildContext, bool)? headerBuilder;
  final Widget Function(BuildContext, bool)? footerBuilder;

  const _SidebarPanel({
    required this.items,
    required this.controller,
    required this.expanded,
    required this.mobile,
    required this.duration,
    this.headerBuilder,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: VeloraColors.navGradient,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(top: -70, left: -50, child: _AuroraBlob()),
          SafeArea(
            left: false,
            right: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerBuilder?.call(context, expanded) ??
                      _BrandHeader(
                        expanded: expanded,
                        duration: duration,
                        showClose: mobile,
                        onClose: controller.closeDrawer,
                      ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final bool startsSection =
                            item.section != null &&
                            (index == 0 ||
                                items[index - 1].section != item.section);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (startsSection)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  top: index == 0 ? 0 : 18,
                                  bottom: 8,
                                ),
                                child: _FadingLabel(
                                  expanded: expanded,
                                  duration: duration,
                                  child: Text(
                                    item.section!,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white.withValues(
                                        alpha: 0.45,
                                      ),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            _NavTile(
                              item: item,
                              index: index,
                              controller: controller,
                              expanded: expanded,
                              duration: duration,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (footerBuilder != null) ...[
                    const SizedBox(height: 10),
                    footerBuilder!(context, expanded),
                  ],
                  if (!mobile) ...[
                    const SizedBox(height: 10),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 8),
                    _CollapseButton(
                      expanded: expanded,
                      duration: duration,
                      onTap: controller.toggleMode,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slow drifting light behind the panel — the only ambient motion in here.
class _AuroraBlob extends StatelessWidget {
  const _AuroraBlob();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child:
          Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      VeloraColors.secondary.withValues(alpha: 0.38),
                      VeloraColors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: 46,
                duration: const Duration(milliseconds: 7000),
                curve: Curves.easeInOut,
              )
              .scaleXY(
                begin: 1,
                end: 1.12,
                duration: const Duration(milliseconds: 7000),
              ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool expanded;
  final Duration duration;
  final bool showClose;
  final VoidCallback onClose;

  const _BrandHeader({
    required this.expanded,
    required this.duration,
    required this.showClose,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: VeloraColors.brandGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: VeloraColors.glow(VeloraColors.primary, opacity: 0.45),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FadingLabel(
            expanded: expanded,
            duration: duration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Velora',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Shop smarter, live better',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showClose)
          IconButton(
            onPressed: onClose,
            splashRadius: 20,
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
      ],
    );
  }
}

class _FadingLabel extends StatelessWidget {
  final bool expanded;
  final Duration duration;
  final Widget child;

  const _FadingLabel({
    required this.expanded,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      curve: Curves.easeOut,
      opacity: expanded ? 1 : 0,
      child: child,
    );
  }
}

/// Labels are already visible when the panel is wide, so the tooltip only
/// attaches on the icon rail.
class _MaybeTooltip extends StatelessWidget {
  final bool enabled;
  final String message;
  final Widget child;

  const _MaybeTooltip({
    required this.enabled,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 350),
      child: child,
    );
  }
}

class _NavTile extends StatefulWidget {
  final VeloraSidebarItem item;
  final int index;
  final VeloraSidebarController controller;
  final bool expanded;
  final Duration duration;

  const _NavTile({
    required this.item,
    required this.index,
    required this.controller,
    required this.expanded,
    required this.duration,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Obx(() {
      final bool active = widget.controller.selectedIndex.value == widget.index;
      final Color badgeColor = item.badgeColor ?? VeloraColors.pink;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: _MaybeTooltip(
          enabled: !widget.expanded,
          message: item.label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.transparent,
              onTap: () {
                widget.controller.selectItem(widget.index);
                item.onTap?.call();
              },
              child: AnimatedContainer(
                duration: widget.duration,
                curve: Curves.easeOutCubic,
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 3),
                transform: Matrix4.translationValues(
                  !active && _hover ? 4 : 0,
                  0,
                  0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: active ? VeloraColors.brandGradient : null,
                  color: !active && _hover
                      ? Colors.white.withValues(alpha: 0.07)
                      : null,
                  boxShadow: active
                      ? VeloraColors.glow(VeloraColors.primary, opacity: 0.45)
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedScale(
                            duration: widget.duration,
                            curve: Curves.easeOutBack,
                            scale: active ? 1.12 : 1,
                            child: Icon(
                              active
                                  ? (item.activeIcon ?? item.icon)
                                  : item.icon,
                              size: 20,
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                          // On the rail the counter collapses into a dot.
                          if (item.badge != null && !widget.expanded)
                            Positioned(
                              top: 8,
                              right: 14,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: VeloraColors.navyMid,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FadingLabel(
                        expanded: widget.expanded,
                        duration: widget.duration,
                        child: Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      _FadingLabel(
                        expanded: widget.expanded,
                        duration: widget.duration,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white.withValues(alpha: 0.22)
                                : badgeColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.badge!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : badgeColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CollapseButton extends StatelessWidget {
  final bool expanded;
  final Duration duration;
  final VoidCallback onTap;

  const _CollapseButton({
    required this.expanded,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: expanded ? 'Collapse menu' : 'Expand menu',
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: VeloraColors.secondary.withValues(alpha: 0.45),
                        ),
                      ),
                      child: AnimatedRotation(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        turns: expanded ? 0 : 0.5,
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _FadingLabel(
                    expanded: expanded,
                    duration: duration,
                    child: Text(
                      'Collapse menu',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ready-made profile card for the sidebar footer.
class VeloraSidebarProfile extends StatelessWidget {
  final bool expanded;
  final String name;
  final String role;
  final String? imageUrl;
  final VoidCallback? onTap;

  const VeloraSidebarProfile({
    super.key,
    required this.expanded,
    required this.name,
    required this.role,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: VeloraColors.brandGradient,
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: imageUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  opacity: expanded ? 1 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        role,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drop-in responsive shell: docked sidebar on wide screens, slide-over
/// drawer plus top bar on phones. Wrap your routed page in `child`.
class VeloraNavShell extends StatelessWidget {
  final List<VeloraSidebarItem> items;
  final Widget child;
  final String title;
  final List<Widget> actions;
  final Widget Function(BuildContext context, bool expanded)? headerBuilder;
  final Widget Function(BuildContext context, bool expanded)? footerBuilder;

  const VeloraNavShell({
    super.key,
    required this.items,
    required this.child,
    this.title = 'Velora',
    this.actions = const [],
    this.headerBuilder,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final c = VeloraSidebarController.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => c.syncLayout(constraints.maxWidth),
        );

        return Obx(() {
          final bool mobile = c.isMobile;
          final bool open = c.isOpen.value;

          return Scaffold(
            backgroundColor: VeloraColors.ink50,
            body: Stack(
              children: [
                Row(
                  children: [
                    if (!mobile)
                      VeloraSidebar(
                        items: items,
                        controller: c,
                        headerBuilder: headerBuilder,
                        footerBuilder: footerBuilder,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          if (mobile)
                            _MobileTopBar(
                              title: title,
                              actions: actions,
                              controller: c,
                            ),
                          Expanded(child: child),
                        ],
                      ),
                    ),
                  ],
                ),
                if (mobile) ...[
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !open,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        opacity: open ? 1 : 0,
                        child: GestureDetector(
                          onTap: c.closeDrawer,
                          child: Container(
                            color: VeloraColors.ink900.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !open,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        offset: open ? Offset.zero : const Offset(-1, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: VeloraSidebar(
                            items: items,
                            controller: c,
                            headerBuilder: headerBuilder,
                            footerBuilder: footerBuilder,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        });
      },
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final VeloraSidebarController controller;

  const _MobileTopBar({
    required this.title,
    required this.actions,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: VeloraColors.ink900.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                onPressed: controller.toggleDrawer,
                tooltip: 'Open menu',
                icon: Obx(
                  () => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: Tween<double>(begin: 0.6, end: 1).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      controller.isOpen.value
                          ? Icons.close_rounded
                          : Icons.menu_rounded,
                      key: ValueKey(controller.isOpen.value),
                      color: VeloraColors.ink900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VeloraColors.ink900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ...actions,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
