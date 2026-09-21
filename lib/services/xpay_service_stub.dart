import '../models/payment_model.dart';

class XPayService {
  static Future<PaymentResult> pay({
    required PaymentSession session,
    required String customerName,
  }) async {
    return const PaymentResult.failed(
      message: 'XPay is not available on this platform.',
    );
  }
}
