import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which layout the shell is currently in.
enum SidebarLayout {
  /// Phones / small web windows — sidebar slides in over the content.
  mobile,

  /// Tablets — sidebar is docked but collapsed to an icon rail.
  tablet,

  /// Desktop — sidebar is docked and wide.
  desktop,
}

class VeloraSidebarController extends GetxController {
  /// Grab (or lazily create) the shared instance.
  static VeloraSidebarController get instance =>
      Get.isRegistered<VeloraSidebarController>()
      ? Get.find<VeloraSidebarController>()
      : Get.put(VeloraSidebarController(), permanent: true);

  // Breakpoints
  static const double mobileMaxWidth = 800;
  static const double tabletMaxWidth = 1200;

  /// Only meaningful on [SidebarLayout.mobile] — the overlay drawer.
  final RxBool isOpen = false.obs;

  /// The user's docked preference: true = wide, false = icon rail.
  final RxBool isExtended = true.obs;

  /// Temporary widening while the pointer rests on a collapsed rail.
  final RxBool hoverPeek = false.obs;

  final RxInt selectedIndex = 0.obs;
  final Rx<SidebarLayout> layout = SidebarLayout.desktop.obs;

  Timer? _peekTimer;
  bool _selectionInitialized = false;
  bool _restored = false;

  static const String _prefsKey = 'velora_sidebar_extended';

  bool get isMobile => layout.value == SidebarLayout.mobile;
  bool get isDesktop => layout.value == SidebarLayout.desktop;

  /// The width the panel should actually render at right now.
  bool get expanded => isMobile || isExtended.value || hoverPeek.value;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefsKey);
      _restored = true;
      if (saved != null && !isMobile) isExtended.value = saved;
    } catch (_) {
      _restored = true; // storage is optional, never block the UI
    }
  }

  Future<void> _persist() async {
    if (!_restored) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, isExtended.value);
    } catch (_) {}
  }

  // ---------------- layout ----------------

  /// Call from a `LayoutBuilder` / `MediaQuery` in a post-frame callback.
  void syncLayout(double width) {
    final SidebarLayout next = width < mobileMaxWidth
        ? SidebarLayout.mobile
        : (width < tabletMaxWidth
              ? SidebarLayout.tablet
              : SidebarLayout.desktop);

    if (next == layout.value) return;
    layout.value = next;
    hoverPeek.value = false;

    switch (next) {
      case SidebarLayout.mobile:
        isOpen.value = false; // start hidden, opened by the menu button
        break;
      case SidebarLayout.tablet:
        isOpen.value = true;
        isExtended.value = false; // rail by default on medium screens
        break;
      case SidebarLayout.desktop:
        isOpen.value = true;
        break;
    }
  }

  // ---------------- mobile drawer ----------------

  void openDrawer() => isOpen.value = true;
  void closeDrawer() => isOpen.value = false;
  void toggleDrawer() => isOpen.value = !isOpen.value;

  // ---------------- hover peek (desktop / tablet rail) ----------------

  void onPanelEnter() {
    if (isMobile || isExtended.value) return;
    _peekTimer?.cancel();
    hoverPeek.value = true;
  }

  void onPanelExit() {
    if (isMobile) return;
    _peekTimer?.cancel();
    // Small grace window so a quick pointer wobble doesn't collapse it.
    _peekTimer = Timer(const Duration(milliseconds: 180), () {
      hoverPeek.value = false;
    });
  }

  // ---------------- wide / rail ----------------

  void toggleMode() {
    isExtended.value = !isExtended.value;
    hoverPeek.value = false;
    _persist();
  }

  // ---------------- selection ----------------

  void selectItem(int index) {
    selectedIndex.value = index;
    if (isMobile) {
      // Let the tap ripple play before the drawer slides away.
      Future.delayed(const Duration(milliseconds: 120), closeDrawer);
    }
  }

  /// Seeds the highlight from whichever item was marked `isActive`,
  /// without overwriting the user's taps on later rebuilds.
  void ensureInitialSelection(int index) {
    if (_selectionInitialized || index < 0) return;
    _selectionInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedIndex.value = index;
    });
  }

  /// Use when navigation happens from somewhere other than the sidebar
  /// (deep link, redirect, back button) and the highlight must follow.
  void syncSelection(int index) {
    if (index >= 0) selectedIndex.value = index;
  }

  @override
  void onClose() {
    _peekTimer?.cancel();
    super.onClose();
  }
}
