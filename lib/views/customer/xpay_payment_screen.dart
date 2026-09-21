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
      final String status =
          result.status?.toString().trim().toLowerCase() ?? '';
      final String message = result.message?.toString().trim() ?? '';

      // Explicit failure reported by XPay.
      if (hasError ||
          status == 'failed' ||
          status == 'cancelled' ||
          status == 'canceled' ||
          status == 'declined') {
        Get.snackbar(
          'Payment Failed',
          message.isEmpty ? 'XPay could not complete the payment.' : message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Explicit success statuses only.
      //
      // IMPORTANT:
      // Never assume an unknown status means success.
      const successStatuses = <String>{
        'success',
        'succeeded',
        'paid',
        'completed',
      };

      if (successStatuses.contains(status)) {
        Navigator.of(context).pop(
          PaymentResult.success(
            transactionId: widget.transactionId,
            message: message.isEmpty
                ? 'Payment completed successfully.'
                : message,
          ),
        );
        return;
      }

      // Known asynchronous states.
      if (status == 'pending' ||
          status == 'processing' ||
          status == 'requires_action' ||
          status == 'in_progress') {
        Navigator.of(context).pop(
          PaymentResult.pending(
            transactionId: widget.transactionId,
            message: message.isEmpty
                ? 'Payment is being processed. We will verify it shortly.'
                : message,
          ),
        );
        return;
      }

      // UNKNOWN STATUS:
      // Never mark the order as paid.
      // Leave it pending so the backend/webhook can verify the final state.
      Navigator.of(context).pop(
        PaymentResult.pending(
          transactionId: widget.transactionId,
          message: message.isEmpty
              ? 'Payment status is being verified. Please do not retry immediately.'
              : 'Payment status is being verified: $message',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      // A communication/API error is also NOT a successful payment.
      Get.snackbar(
        'Payment Verification',
        'We could not confirm the payment yet. Please try again later.',
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

  // Future<void> _confirmPayment() async {
  //   if (_paying) return;

  //   setState(() => _paying = true);

  //   try {
  //     final dynamic result = await _controller.confirmPayment(
  //       customerName: widget.customerName,
  //       clientSecret: widget.clientSecret,
  //       encryptionsKeys: widget.encryptionKey,
  //     );

  //     final bool hasError = result.error == true;
  //     final String? status = result.status?.toString().toLowerCase();
  //     final String message = result.message?.toString() ?? '';

  //     if (!mounted) return;

  //     if (hasError || status == 'failed') {
  //       Get.snackbar(
  //         'Payment Failed',
  //         message.isEmpty ? 'XPay could not complete the payment.' : message,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return;
  //     }

  //     if (status == 'pending' || status == 'processing') {
  //       Navigator.of(context).pop(
  //         PaymentResult.pending(
  //           transactionId: widget.transactionId,
  //           message: message.isEmpty ? 'Payment is processing.' : message,
  //         ),
  //       );
  //       return;
  //     }

  //     Navigator.of(context).pop(
  //       PaymentResult.success(
  //         transactionId: widget.transactionId,
  //         message: message.isEmpty ? 'Payment completed.' : message,
  //       ),
  //     );
  //   } catch (error) {
  //     if (!mounted) return;
  //     Get.snackbar(
  //       'Payment Failed',
  //       error.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _paying = false);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XPay Payment')),
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
                          child: XPayElementWidget(controller: _controller),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
