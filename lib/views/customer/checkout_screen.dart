import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/controllers/auth_controller.dart';
import 'package:e_commerce/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:e_commerce/controllers/order_controller.dart';
import 'package:e_commerce/models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController cartController = Get.find<CartController>();

  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (cartController.isEmpty) {
          return _EmptyCheckout();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            if (isDesktop) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(30.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildCheckoutForm()),
                        SizedBox(width: 24.w),
                        SizedBox(width: 360.w, child: _buildOrderSummary()),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildCheckoutForm(),
                  SizedBox(height: 20.h),
                  _buildOrderSummary(),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // ===========================================================================
  // CHECKOUT FORM
  // ===========================================================================

  Widget _buildCheckoutForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Iconsax.location, title: 'Delivery Address'),

          SizedBox(height: 12.h),

          _CheckoutCard(
            child: Column(
              children: [
                _textField(
                  controller: nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Iconsax.user,
                ),

                SizedBox(height: 14.h),

                _textField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: '03XX XXXXXXX',
                  icon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 14.h),

                _textField(
                  controller: addressController,
                  label: 'Complete Address',
                  hint: 'House / Street / Area',
                  icon: Iconsax.home,
                  maxLines: 2,
                ),

                SizedBox(height: 14.h),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Column(
                        children: [
                          _textField(
                            controller: cityController,
                            label: 'City',
                            hint: 'Lahore',
                            icon: Iconsax.building,
                          ),
                          SizedBox(height: 14.h),
                          _textField(
                            controller: postalCodeController,
                            label: 'Postal Code',
                            hint: '54000',
                            icon: Iconsax.location,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: cityController,
                            label: 'City',
                            hint: 'Lahore',
                            icon: Iconsax.building,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _textField(
                            controller: postalCodeController,
                            label: 'Postal Code',
                            hint: '54000',
                            icon: Iconsax.location,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // -------------------------------------------------------------------
          // PAYMENT METHOD
          // -------------------------------------------------------------------
          _sectionTitle(icon: Iconsax.card, title: 'Payment Method'),

          SizedBox(height: 12.h),

          _CheckoutCard(
            child: Column(
              children: [
                _PaymentOption(
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when your order arrives',
                  icon: Iconsax.money_4,
                  value: 'Cash on Delivery',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),

                SizedBox(height: 10.h),

                _PaymentOption(
                  title: 'Card Payment',
                  subtitle: 'Visa, Mastercard and other cards',
                  icon: Iconsax.card,
                  value: 'Card Payment',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // -------------------------------------------------------------------
          // PLACE ORDER
          // -------------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: _placeOrder,
              icon: Icon(Iconsax.tick_circle, size: 18.sp),
              label: Text(
                'Place Order',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ORDER SUMMARY
  // ===========================================================================

  Widget _buildOrderSummary() {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 16.h),

          ...cartController.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(
                      Iconsax.shopping_bag,
                      size: 20.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Qty: ${item.quantity}',
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(color: Colors.grey.shade200),
          ),

          SizedBox(height: 8.h),

          _summaryRow(
            'Subtotal',
            'Rs. ${cartController.subtotal.toStringAsFixed(0)}',
          ),

          SizedBox(height: 9.h),

          _summaryRow(
            'Shipping',
            cartController.shipping == 0
                ? 'FREE'
                : 'Rs. ${cartController.shipping.toStringAsFixed(0)}',
            valueColor: cartController.shipping == 0
                ? Colors.green
                : Colors.black,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(color: Colors.grey.shade200),
          ),

          _summaryRow(
            'Total',
            'Rs. ${cartController.total.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PLACE ORDER
  // ===========================================================================

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // CHECK LOGIN
    // ----------------------------------------------------------

    final String userId = authController.userId;

    if (userId.trim().isEmpty) {
      Get.snackbar(
        'Login Required',
        'Please login before placing an order.',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.toNamed(AppRoutes.login);
      return;
    }

    // ----------------------------------------------------------
    // CHECK CART
    // ----------------------------------------------------------

    if (cartController.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add products before placing an order.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ----------------------------------------------------------
    // PAYMENT
    // ----------------------------------------------------------

    // For now we create real orders only for COD.
    // Stripe / PayFast will be connected separately.
    if (paymentMethod != 'Cash on Delivery') {
      Get.snackbar(
        'Payment Coming Soon',
        'Online card payment will be connected next.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ----------------------------------------------------------
    // CONVERT CART ITEMS → ORDER ITEMS
    // ----------------------------------------------------------

    final List<OrderItem> orderItems = cartController.items.map((cartItem) {
      return OrderItem(
        productId: cartItem.productId,
        productName: cartItem.productName,
        productImage: cartItem.productImage,
        price: cartItem.price,
        quantity: cartItem.quantity,
        variationId: cartItem.variationId,
        variationName: cartItem.variationName,
        variationValue: cartItem.variationValue,
      );
    }).toList();

    // ----------------------------------------------------------
    // SHIPPING ADDRESS
    // ----------------------------------------------------------

    final ShippingAddress shippingAddress = ShippingAddress(
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      country: 'Pakistan',
    );

    // ----------------------------------------------------------
    // CREATE ORDER
    // ----------------------------------------------------------

    final OrderModel order = OrderModel(
      id: '',
      userId: userId,
      items: orderItems,
      subtotal: cartController.subtotal,
      shippingFee: cartController.shipping,
      discount: 0,
      total: cartController.total,
      currency: 'PKR',
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
      transactionId: null,
      orderStatus: 'pending',
      shippingAddress: shippingAddress,
    );

    // ----------------------------------------------------------
    // SAVE TO FIREBASE
    // ----------------------------------------------------------

    final createdOrder = await orderController.createOrder(order);

    if (createdOrder == null) {
      return;
    }

    // ----------------------------------------------------------
    // CLEAR CART
    // ----------------------------------------------------------

    cartController.clearCart();

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    Get.offNamed(
      AppRoutes.orderSuccess,
      arguments: {
        'orderId': createdOrder.id,
        'total': createdOrder.total,
        'paymentMethod': createdOrder.paymentMethod,
      },
    );
    // Get.dialog(
    //   PopScope(
    //     canPop: false,
    //     child: AlertDialog(
    //       title: Row(
    //         children: [
    //           const Icon(Iconsax.tick_circle, color: Colors.green),
    //           const SizedBox(width: 10),
    //           Text(
    //             'Order Placed!',
    //             style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
    //           ),
    //         ],
    //       ),
    //       content: Text(
    //         'Your order has been placed successfully.\n\n'
    //         'Order ID:\n${createdOrder.id}\n\n'
    //         'Total: PKR ${createdOrder.total.toStringAsFixed(0)}\n\n'
    //         'Payment: Cash on Delivery',
    //         style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Get.back();
    //             Get.offAllNamed(AppRoutes.home);
    //           },
    //           child: Text(
    //             'Continue Shopping',
    //             style: GoogleFonts.poppins(
    //               color: const Color(0xFF6846E8),
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   barrierDismissible: false,
    // );
  }
  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.black),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      style: GoogleFonts.poppins(fontSize: 11.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 17.sp),
        labelStyle: GoogleFonts.poppins(fontSize: 10.sp),
        hintStyle: GoogleFonts.poppins(
          fontSize: 10.sp,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUMMARY ROW
  // ===========================================================================

  Widget _summaryRow(
    String title,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.sp : 10.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 15.sp : 10.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CHECKOUT CARD
// =============================================================================

class _CheckoutCard extends StatelessWidget {
  final Widget child;

  const _CheckoutCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

// =============================================================================
// PAYMENT OPTION
// =============================================================================

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 19.sp, color: Colors.black),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY CHECKOUT
// =============================================================================

class _EmptyCheckout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.shopping_cart,
              size: 50.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add products before proceeding to checkout.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
