import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/order_model.dart';
import '../models/payment_model.dart';
import 'stripe_service.dart';
import 'xpay_service.dart';

class PaymentService {
  PaymentService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<PaymentSession> createPaymentSession({
    required OrderModel order,
    required PaymentGateway gateway,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String platform,
  }) async {
    final callable = _functions.httpsCallable('createPaymentSession');

    final result = await callable.call(<String, dynamic>{
      'orderId': order.id,
      'gateway': gateway.key,
      'platform': platform,
      'customer': <String, dynamic>{
        'name': customerName,
        'email': customerEmail,
        'phone': customerPhone,
      },
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return PaymentSession.fromMap(data);
  }

  static Future<PaymentResult> verifyPayment({
    required String orderId,
    required PaymentGateway gateway,
    String? transactionId,
  }) async {
    final callable = _functions.httpsCallable('verifyPayment');

    final result = await callable.call(<String, dynamic>{
      'orderId': orderId,
      'gateway': gateway.key,
      'transactionId': transactionId,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final status = data['status']?.toString().toLowerCase();

    if (status == 'paid' || status == 'succeeded') {
      return PaymentResult.success(
        transactionId:
            data['transactionId']?.toString() ?? transactionId,
        message: data['message']?.toString(),
      );
    }

    if (status == 'pending' || status == 'processing') {
      return PaymentResult.pending(
        transactionId:
            data['transactionId']?.toString() ?? transactionId,
        message: data['message']?.toString(),
      );
    }

    return PaymentResult.failed(
      transactionId: data['transactionId']?.toString() ?? transactionId,
      message: data['message']?.toString() ?? 'Payment verification failed.',
    );
  }

  static Future<PaymentResult> pay({
    required PaymentSession session,
    required PaymentGateway gateway,
    required String customerName,
  }) async {
    switch (gateway) {
      case PaymentGateway.stripe:
        if (kIsWeb) {
          final url = session.checkoutUrl;
          if (url == null || url.isEmpty) {
            return const PaymentResult.failed(
              message: 'Stripe checkout URL was not returned.',
            );
          }
          await _openHostedCheckout(url);
          return PaymentResult.pending(
            transactionId: session.transactionId,
            message: 'Stripe checkout opened in the browser.',
          );
        }

        return StripeService.payWithPaymentSheet(
          clientSecret: session.clientSecret!,
          publishableKey: session.publishableKey!,
          transactionId: session.transactionId,
        );

      case PaymentGateway.payfast:
        final url = session.checkoutUrl;
        if (url == null || url.isEmpty) {
          return const PaymentResult.failed(
            message: 'PayFast checkout URL was not returned.',
          );
        }
        await _openHostedCheckout(url);
        return PaymentResult.pending(
          transactionId: session.transactionId,
          message: 'PayFast checkout opened in the browser.',
        );

      case PaymentGateway.xpay:
        return XPayService.pay(
          session: session,
          customerName: customerName,
        );
    }
  }

  static Future<void> _openHostedCheckout(String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );

    if (!launched) {
      throw StateError('Unable to open the payment page.');
    }
  }

}
