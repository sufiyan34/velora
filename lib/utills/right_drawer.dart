import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';

/// Slides a panel in from the right — full width on mobile, a fixed width
/// on tablet/desktop. Used for the "Add/edit product" form so it reads as a
/// working panel rather than a full page navigation.
Future<T?> showRightDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 460,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.42),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      final panelWidth = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : maxWidth;
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 12,
          color: Colors.transparent,
          child: SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: builder(context),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
