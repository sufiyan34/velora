import 'package:get/get.dart';

import '../models/payment_model.dart';
import '../views/customer/xpay_payment_screen.dart';

class XPayService {
  static Future<PaymentResult> pay({
    required PaymentSession session,
    required String customerName,
  }) async {
    if (session.publicKey == null ||
        session.accountId == null ||
        session.clientSecret == null ||
        session.encryptionKey == null) {
      return const PaymentResult.failed(
        message: 'XPay payment configuration is incomplete.',
      );
    }

    final result = await Get.to<PaymentResult>(
      () => XPayPaymentScreen(
        publicKey: session.publicKey!,
        accountId: session.accountId!,
        clientSecret: session.clientSecret!,
        encryptionKey: session.encryptionKey!,
        customerName: customerName,
        transactionId: session.transactionId,
      ),
      fullscreenDialog: true,
    );

    return result ??
        const PaymentResult.failed(message: 'Payment screen was closed.');
  }
}
