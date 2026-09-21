import 'package:flutter_stripe/flutter_stripe.dart';

import '../models/payment_model.dart';

class StripeService {
  StripeService._();

  static String? _configuredPublishableKey;

  static Future<void> configure(String publishableKey) async {
    if (publishableKey.trim().isEmpty) {
      throw StateError('Stripe publishable key was not returned by the server.');
    }

    if (_configuredPublishableKey == publishableKey) {
      return;
    }

    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
    _configuredPublishableKey = publishableKey;
  }

  static Future<PaymentResult> payWithPaymentSheet({
    required String clientSecret,
    required String publishableKey,
    String? transactionId,
  }) async {
    await configure(publishableKey);

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Velora',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        transactionId: transactionId,
        message: 'Payment completed. Verifying with the server.',
      );
    } on StripeException catch (error) {
      final code = error.error.code;
      if (code.toString().toLowerCase().contains('canceled')) {
        return const PaymentResult.failed(message: 'Payment was cancelled.');
      }

      return PaymentResult.failed(
        transactionId: transactionId,
        message: error.error.localizedMessage ?? 'Stripe payment failed.',
      );
    } catch (error) {
      return PaymentResult.failed(
        transactionId: transactionId,
        message: error.toString(),
      );
    }
  }
}
