import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/payment_model.dart';

class XPayService {
  static Future<PaymentResult> pay({
    required PaymentSession session,
    required String customerName,
  }) async {
    final url = session.checkoutUrl;
    if (url == null || url.isEmpty) {
      return const PaymentResult.failed(
        message:
            'XPay web needs the XPay Web SDK or a merchant-provided hosted checkout URL.',
      );
    }

    final launched = await launchUrl(
      Uri.parse(url),
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );

    if (!launched) {
      return const PaymentResult.failed(
        message: 'Unable to open XPay checkout in the browser.',
      );
    }

    return PaymentResult.pending(
      transactionId: session.transactionId,
      message: 'XPay checkout opened in the browser.',
    );
  }
}
