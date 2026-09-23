import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/payment_model.dart';

class XPayService {
  static Future<PaymentResult> pay({
    required PaymentSession session,
    required String customerName,
  }) async {
    final url = session.checkoutUrl;

    if (url == null || url.trim().isEmpty) {
      return const PaymentResult.failed(
        message: 'XPay did not return a hosted checkout URL.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return const PaymentResult.failed(
        message: 'The XPay checkout URL is invalid.',
      );
    }

    final launched = await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    );

    if (!launched) {
      return const PaymentResult.failed(
        message: 'Unable to open XPay checkout in the browser.',
      );
    }

    return PaymentResult.pending(
      transactionId: session.transactionId,
      message:
          'XPay checkout opened. Your order will be marked paid after gateway verification.',
    );
  }
}
