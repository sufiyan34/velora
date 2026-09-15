import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// ===============================================================
/// VELORA CUSTOM DIALOG
/// ===============================================================
///
/// Usage:
///
/// CustomDialog.success(
///   context,
///   title: 'Order Placed',
///   message: 'Your order has been placed successfully.',
/// );
///
/// CustomDialog.error(
///   context,
///   title: 'Payment Failed',
///   message: 'We could not process your payment.',
/// );
///
/// CustomDialog.warning(
///   context,
///   title: 'Stock Warning',
///   message: 'Only 2 items are left in stock.',
/// );
///
/// CustomDialog.confirm(
///   context,
///   title: 'Delete Product?',
///   message: 'This action cannot be undone.',
///   onConfirm: () {
///     // delete product
///   },
/// );
///
/// CustomDialog.loading(context);
///
/// ===============================================================

class CustomDialog {
  CustomDialog._();

  // ===============================================================
  // VELORA COLORS
  // ===============================================================

  static const Color primaryColor = Color(0xFF6C4CF1);
  static const Color secondaryColor = Color(0xFF8B5CF6);

  // ===============================================================
  // DEFAULT TEXT
  // ===============================================================

  static const String defaultTitle = 'Velora';
  static const String defaultMessage = 'Something happened.';

  // ===============================================================
  // INTERNAL SHOW METHOD
  // ===============================================================

  static void _show({
    BuildContext? context,

    required DialogType dialogType,

    String? title,
    String? message,

    Widget? body,

    AnimType animType = AnimType.scale,

    VoidCallback? onOk,
    VoidCallback? onCancel,

    String okText = 'OK',
    String cancelText = 'Cancel',

    bool showOkButton = true,
    bool showCancelButton = false,

    bool dismissOnTouchOutside = true,
    bool dismissOnBackKeyPress = true,

    bool showCloseIcon = true,

    bool headerAnimationLoop = false,

    bool reverseButtonOrder = false,

    Color? backgroundColor,

    Widget? customHeader,

    String? lottieAsset,

    Duration? autoHide,
  }) {
    final BuildContext? dialogContext =
        context ?? Get.overlayContext ?? Get.context;

    if (dialogContext == null) {
      debugPrint('CustomDialog: Unable to find a valid BuildContext.');
      return;
    }

    final screenWidth = MediaQuery.of(dialogContext).size.width;

    final double dialogWidth = screenWidth >= 1200
        ? 520.w
        : screenWidth >= 700
        ? 470.w
        : 390.w;

    Widget? header = customHeader;

    // ---------------------------------------------------------------
    // OPTIONAL LOTTIE HEADER
    // ---------------------------------------------------------------

    if (header == null && lottieAsset != null && lottieAsset.isNotEmpty) {
      header = SizedBox(
        width: 130.w,
        height: 130.h,
        child: Lottie.asset(lottieAsset, fit: BoxFit.contain, repeat: true),
      );
    }

    final String finalTitle = title == null || title.trim().isEmpty
        ? defaultTitle
        : title;

    final String finalMessage = message == null || message.trim().isEmpty
        ? defaultMessage
        : message;

    AwesomeDialog(
      context: dialogContext,
      dialogType: dialogType,

      // -------------------------------------------------------------
      // CUSTOM HEADER
      // -------------------------------------------------------------
      customHeader: header,

      // -------------------------------------------------------------
      // CONTENT
      // -------------------------------------------------------------
      title: finalTitle,
      desc: finalMessage,
      body: body,

      // -------------------------------------------------------------
      // SIZE / DESIGN
      // -------------------------------------------------------------
      width: dialogWidth,
      dialogBackgroundColor:
          backgroundColor ??
          Theme.of(dialogContext).dialogTheme.backgroundColor,

      barrierColor: Colors.black.withValues(alpha: 0.60),

      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),

      buttonsBorderRadius: BorderRadius.circular(14.r),

      // -------------------------------------------------------------
      // ANIMATION
      // -------------------------------------------------------------
      animType: animType,
      headerAnimationLoop: headerAnimationLoop,

      // -------------------------------------------------------------
      // DISMISS
      // -------------------------------------------------------------
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnBackKeyPress,

      // -------------------------------------------------------------
      // CLOSE
      // -------------------------------------------------------------
      showCloseIcon: showCloseIcon,

      closeIcon: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 18.sp,
          color: Colors.grey.shade700,
        ),
      ),

      // -------------------------------------------------------------
      // TEXT
      // -------------------------------------------------------------
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 21.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF202020),
      ),

      descTextStyle: GoogleFonts.poppins(
        fontSize: 14.sp,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF686868),
      ),

      // -------------------------------------------------------------
      // OK BUTTON
      // -------------------------------------------------------------
      btnOkText: okText,

      btnOkColor: primaryColor,

      btnOkIcon: Icons.check_rounded,

      btnOkOnPress: showOkButton ? onOk : null,

      // -------------------------------------------------------------
      // CANCEL BUTTON
      // -------------------------------------------------------------
      btnCancelText: cancelText,

      btnCancelColor: Colors.grey.shade700,

      btnCancelIcon: Icons.close_rounded,

      btnCancelOnPress: showCancelButton ? onCancel : null,

      // -------------------------------------------------------------
      // BUTTON STYLE
      // -------------------------------------------------------------
      buttonsTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
      ),

      // -------------------------------------------------------------
      // ORDER
      // -------------------------------------------------------------
      reverseBtnOrder: reverseButtonOrder,

      // -------------------------------------------------------------
      // AUTO HIDE
      // -------------------------------------------------------------
      autoHide: autoHide,
    ).show();
  }

  // ===============================================================
  // SUCCESS
  // ===============================================================

  static void success(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onOk,

    String okText = 'Continue',

    bool showCloseIcon = true,

    bool dismissOnTouchOutside = true,

    AnimType animType = AnimType.scale,

    String? lottieAsset,
  }) {
    _show(
      context: context,
      dialogType: DialogType.success,

      title: title ?? 'Success',
      message: message ?? 'Your request has been completed successfully.',

      okText: okText,

      onOk: onOk,

      animType: animType,

      showCloseIcon: showCloseIcon,

      dismissOnTouchOutside: dismissOnTouchOutside,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // ERROR / FAILURE
  // ===============================================================

  static void error(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onOk,

    String okText = 'Try Again',

    bool showCloseIcon = true,

    AnimType animType = AnimType.rightSlide,

    String? lottieAsset,
  }) {
    _show(
      context: context,
      dialogType: DialogType.error,

      title: title ?? 'Something Went Wrong',
      message:
          message ?? 'We could not complete your request. Please try again.',

      okText: okText,

      onOk: onOk,

      animType: animType,

      showCloseIcon: showCloseIcon,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // WARNING
  // ===============================================================

  static void warning(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onOk,

    String okText = 'Got It',

    bool showCloseIcon = true,

    AnimType animType = AnimType.topSlide,

    String? lottieAsset,
  }) {
    _show(
      context: context,
      dialogType: DialogType.warning,

      title: title ?? 'Warning',
      message: message ?? 'Please review the information before continuing.',

      okText: okText,

      onOk: onOk,

      animType: animType,

      showCloseIcon: showCloseIcon,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // INFO
  // ===============================================================

  static void info(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onOk,

    String okText = 'Understood',

    bool showCloseIcon = true,

    AnimType animType = AnimType.rightSlide,

    String? lottieAsset,
  }) {
    _show(
      context: context,
      dialogType: DialogType.info,

      title: title ?? 'Information',
      message: message ?? 'Here is some useful information for you.',

      okText: okText,

      onOk: onOk,

      animType: animType,

      showCloseIcon: showCloseIcon,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // QUESTION
  // ===============================================================

  static void question(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onConfirm,
    VoidCallback? onCancel,

    String confirmText = 'Yes',
    String cancelText = 'No',

    bool showCloseIcon = true,

    AnimType animType = AnimType.bottomSlide,

    String? lottieAsset,
  }) {
    _show(
      context: context,
      dialogType: DialogType.question,

      title: title ?? 'Are You Sure?',
      message: message ?? 'Please confirm that you want to continue.',

      okText: confirmText,
      cancelText: cancelText,

      onOk: onConfirm,
      onCancel: onCancel,

      showOkButton: true,
      showCancelButton: true,

      animType: animType,

      showCloseIcon: showCloseIcon,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // CONFIRM
  // ===============================================================

  static void confirm(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onConfirm,
    VoidCallback? onCancel,

    String confirmText = 'Confirm',
    String cancelText = 'Cancel',

    bool showCloseIcon = true,

    AnimType animType = AnimType.scale,

    bool reverseButtonOrder = false,
  }) {
    _show(
      context: context,

      dialogType: DialogType.question,

      title: title ?? 'Confirm Action',

      message: message ?? 'Are you sure you want to continue with this action?',

      okText: confirmText,
      cancelText: cancelText,

      onOk: onConfirm,
      onCancel: onCancel,

      showOkButton: true,
      showCancelButton: true,

      animType: animType,

      showCloseIcon: showCloseIcon,

      reverseButtonOrder: reverseButtonOrder,
    );
  }

  // ===============================================================
  // DELETE
  // ===============================================================

  static void delete(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onDelete,
    VoidCallback? onCancel,

    String deleteText = 'Delete',
    String cancelText = 'Cancel',

    bool showCloseIcon = true,
  }) {
    _show(
      context: context,

      dialogType: DialogType.error,

      title: title ?? 'Delete Item?',

      message:
          message ??
          'This action cannot be undone. Are you sure you want to delete this item?',

      okText: deleteText,
      cancelText: cancelText,

      onOk: onDelete,
      onCancel: onCancel,

      showOkButton: true,
      showCancelButton: true,

      animType: AnimType.scale,

      showCloseIcon: showCloseIcon,

      reverseButtonOrder: true,
    );
  }

  // ===============================================================
  // ALERT
  // ===============================================================

  static void alert(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onOk,

    String okText = 'OK',

    bool showCloseIcon = true,
  }) {
    _show(
      context: context,

      dialogType: DialogType.info,

      title: title ?? 'Alert',

      message: message ?? 'Please pay attention to this message.',

      okText: okText,

      onOk: onOk,

      animType: AnimType.scale,

      showCloseIcon: showCloseIcon,
    );
  }

  // ===============================================================
  // CART SUCCESS
  // ===============================================================

  static void addedToCart(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onContinueShopping,
    VoidCallback? onViewCart,

    String continueText = 'Continue Shopping',
    String cartText = 'View Cart',
  }) {
    _show(
      context: context,

      dialogType: DialogType.success,

      title: title ?? 'Added to Cart',

      message:
          message ??
          'The product has been successfully added to your shopping cart.',

      okText: cartText,
      cancelText: continueText,

      onOk: onViewCart,
      onCancel: onContinueShopping,

      showOkButton: true,
      showCancelButton: true,

      animType: AnimType.bottomSlide,

      showCloseIcon: true,
    );
  }

  // ===============================================================
  // OUT OF STOCK
  // ===============================================================

  static void outOfStock(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onOk,

    String okText = 'Continue Shopping',
  }) {
    _show(
      context: context,

      dialogType: DialogType.warning,

      title: title ?? 'Out of Stock',

      message:
          message ?? 'Unfortunately, this product is currently out of stock.',

      okText: okText,

      onOk: onOk,

      animType: AnimType.topSlide,

      showCloseIcon: true,
    );
  }

  // ===============================================================
  // PAYMENT SUCCESS
  // ===============================================================

  static void paymentSuccess(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onOk,

    String okText = 'View Order',

    String? lottieAsset,
  }) {
    _show(
      context: context,

      dialogType: DialogType.success,

      title: title ?? 'Payment Successful',

      message: message ?? 'Your payment has been processed successfully.',

      okText: okText,

      onOk: onOk,

      animType: AnimType.scale,

      showCloseIcon: true,

      lottieAsset: lottieAsset,
    );
  }

  // ===============================================================
  // PAYMENT FAILED
  // ===============================================================

  static void paymentFailed(
    BuildContext context, {
    String? title,
    String? message,

    VoidCallback? onRetry,
    VoidCallback? onCancel,

    String retryText = 'Retry',
    String cancelText = 'Cancel',
  }) {
    _show(
      context: context,

      dialogType: DialogType.error,

      title: title ?? 'Payment Failed',

      message:
          message ?? 'We could not process your payment. Please try again.',

      okText: retryText,
      cancelText: cancelText,

      onOk: onRetry,
      onCancel: onCancel,

      showOkButton: true,
      showCancelButton: true,

      animType: AnimType.rightSlide,

      showCloseIcon: true,
    );
  }

  // ===============================================================
  // LOADING
  // ===============================================================

  static void loading(
    BuildContext context, {
    String? title,
    String? message,

    String? lottieAsset,
  }) {
    _show(
      context: context,

      dialogType: DialogType.noHeader,

      title: title ?? 'Please Wait',

      message: message ?? 'We are processing your request...',

      showOkButton: false,
      showCancelButton: false,

      showCloseIcon: false,

      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,

      animType: AnimType.scale,

      customHeader: lottieAsset != null
          ? SizedBox(
              width: 100.w,
              height: 100.h,
              child: Lottie.asset(lottieAsset, repeat: true),
            )
          : Container(
              width: 75.w,
              height: 75.w,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3.w,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
    );
  }

  // ===============================================================
  // CUSTOM DIALOG
  // ===============================================================

  static void custom(
    BuildContext context, {
    String? title,
    String? message,

    Widget? body,
    Widget? customHeader,

    VoidCallback? onOk,
    VoidCallback? onCancel,

    String okText = 'OK',
    String cancelText = 'Cancel',

    bool showOkButton = true,
    bool showCancelButton = false,

    DialogType dialogType = DialogType.info,

    AnimType animType = AnimType.scale,

    bool showCloseIcon = true,

    bool dismissOnTouchOutside = true,

    String? lottieAsset,

    Color? backgroundColor,
  }) {
    _show(
      context: context,

      dialogType: dialogType,

      title: title,
      message: message,

      body: body,

      customHeader: customHeader,

      lottieAsset: lottieAsset,

      onOk: onOk,
      onCancel: onCancel,

      okText: okText,
      cancelText: cancelText,

      showOkButton: showOkButton,
      showCancelButton: showCancelButton,

      animType: animType,

      showCloseIcon: showCloseIcon,

      dismissOnTouchOutside: dismissOnTouchOutside,

      backgroundColor: backgroundColor,
    );
  }

  // ===============================================================
  // CLOSE ACTIVE DIALOG
  // ===============================================================

  static void close() {
    Get.back();
  }
}
// ```

// ### How you'll use it

// Success:

// ```dart
// CustomDialog.success(
//   context,
//   title: 'Order Placed!',
//   message: 'Your order #VL-10245 has been placed successfully.',
// );
// ```

// Error:

// ```dart
// CustomDialog.error(
//   context,
//   title: 'Login Failed',
//   message: 'Incorrect email or password.',
// );
// ```

// Warning:

// ```dart
// CustomDialog.warning(
//   context,
//   title: 'Low Stock',
//   message: 'Only 2 pieces are remaining.',
// );
// ```

// Confirmation:

// ```dart
// CustomDialog.confirm(
//   context,
//   title: 'Place Order?',
//   message: 'Are you sure you want to place this order?',
//   onConfirm: () {
//     // place order
//   },
//   onCancel: () {
//     // cancelled
//   },
// );
// ```

// Delete:

// ```dart
// CustomDialog.delete(
//   context,
//   title: 'Delete Product?',
//   message: 'This product will be permanently removed.',
//   onDelete: () {
//     // delete product
//   },
// );
// ```

// Added to cart:

// ```dart
// CustomDialog.addedToCart(
//   context,
//   onViewCart: () {
//     Get.toNamed('/cart');
//   },
//   onContinueShopping: () {
//     Get.back();
//   },
// );
// ```

// Payment:

// ```dart
// CustomDialog.paymentSuccess(
//   context,
//   title: 'Payment Successful!',
//   message: 'Your order has been confirmed.',
//   onOk: () {
//     Get.toNamed('/orders');
//   },
// );
// ```

// Loading:

// ```dart
// CustomDialog.loading(
//   context,
//   message: 'Processing your payment...',
// );
// ```

// Then close it:

// ```dart
// CustomDialog.close();
// ```

// ### Adding your Lottie animations

// You already have:

// ```yaml
// assets:
//   - assets/animations/
// ```

// So you can keep animations such as:

// ```text
// assets/
// └── animations/
//     ├── success.json
//     ├── error.json
//     ├── warning.json
//     ├── loading.json
//     ├── cart.json
//     └── payment.json
// ```

// Then:

// ```dart
// CustomDialog.success(
//   context,
//   title: 'Order Confirmed',
//   message: 'Your order has been placed.',
//   lottieAsset: 'assets/animations/success.json',
// );
// ```

// Lottie supports `Lottie.asset(...)` for local animation assets, and its current package supports Android, iOS, web, Windows, macOS and Linux.

// ### One important thing in your `pubspec.yaml`

// Your current:

// ```yaml
// environment:
//   sdk: ^3.10.0
// ```

// is compatible with the newer Dart versions because `^3.10.0` allows Dart `3.10.x` through `<4.0.0`. Your current Lottie `3.5.1` requires Dart `3.12`, so this is fine on your newer Flutter/Dart setup, but not if you actually run Dart 3.10. Lottie `3.3.3` supports Dart 3.9+.

// Also, your `pubspec.yaml` has `flutter_launcher_icons` listed under both `dependencies` and `dev_dependencies`. You should keep it only where you actually intend to use it; normally launcher-icon generation packages belong in `dev_dependencies`.

// This gives Velora one centralized dialog system, so your product, cart, checkout, authentication, admin, payment, and order screens can all use the same visual language.
