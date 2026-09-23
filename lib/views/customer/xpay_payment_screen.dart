import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpay_element_flutter/xpay_element_flutter.dart'
    show XPayElementController, XPayElementWidget;

import '../../models/payment_model.dart';

class XPayPaymentScreen extends StatefulWidget {
  final String publicKey;
  final String accountId;
  final String clientSecret;
  final String encryptionKey;
  final String customerName;
  final String? transactionId;

  const XPayPaymentScreen({
    super.key,
    required this.publicKey,
    required this.accountId,
    required this.clientSecret,
    required this.encryptionKey,
    required this.customerName,
    this.transactionId,
  });

  @override
  State<XPayPaymentScreen> createState() => _XPayPaymentScreenState();
}

class _XPayPaymentScreenState extends State<XPayPaymentScreen> {
  late final XPayElementController _controller;
  bool _paying = false;

  @override
  void initState() {
    super.initState();

    _controller = XPayElementController(
      publicKey: widget.publicKey,
      accountId: widget.accountId,
    );
    _controller.setClientSecret(widget.clientSecret);
  }

  Future<void> _confirmPayment() async {
    if (_paying) return;

    if (!_controller.isReady()) {
      Get.snackbar(
        'Incomplete Payment',
        'Please complete all required payment fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _paying = true;
    });

    try {
      final result = await _controller.confirmPayment(
        customerName: widget.customerName,
        clientSecret: widget.clientSecret,
        encryptionsKeys: widget.encryptionKey,
      );

      if (!mounted) return;

      final bool hasError = result.error == true;
      final String message = result.message?.toString().trim() ?? '';

      if (hasError) {
        Get.snackbar(
          'Payment Failed',
          message.isEmpty ? 'XPay could not complete the payment.' : message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // The SDK confirms the client-side payment flow. The checkout screen
      // immediately calls the trusted Firebase verifyPayment function, which
      // retrieves the XPay payment intent and checks amount, currency, order
      // reference, and final gateway status before marking the order as paid.
      Navigator.of(context).pop(
        PaymentResult.success(
          transactionId: widget.transactionId,
          message: message.isEmpty
              ? 'Payment submitted. Verifying with XPay...'
              : message,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      Get.snackbar(
        'Payment Error',
        'Unable to submit the payment: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _paying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XPay Payment'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: XPayElementWidget(
                            controller: _controller,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _paying ? null : _confirmPayment,
                      child: _paying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
