enum PaymentGateway {
  stripe,
  payfast,
  xpay,
}

extension PaymentGatewayX on PaymentGateway {
  String get key => switch (this) {
        PaymentGateway.stripe => 'stripe',
        PaymentGateway.payfast => 'payfast',
        PaymentGateway.xpay => 'xpay',
      };

  String get title => switch (this) {
        PaymentGateway.stripe => 'Stripe',
        PaymentGateway.payfast => 'PayFast',
        PaymentGateway.xpay => 'XPay',
      };
}

class PaymentSession {
  final String gateway;
  final String type;
  final String? transactionId;
  final String? clientSecret;
  final String? publishableKey;
  final String? checkoutUrl;
  final String? publicKey;
  final String? accountId;
  final String? encryptionKey;

  const PaymentSession({
    required this.gateway,
    required this.type,
    this.transactionId,
    this.clientSecret,
    this.publishableKey,
    this.checkoutUrl,
    this.publicKey,
    this.accountId,
    this.encryptionKey,
  });

  factory PaymentSession.fromMap(Map<String, dynamic> map) {
    return PaymentSession(
      gateway: map['gateway']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      transactionId: map['transactionId']?.toString(),
      clientSecret: map['clientSecret']?.toString(),
      publishableKey: map['publishableKey']?.toString(),
      checkoutUrl: map['checkoutUrl']?.toString(),
      publicKey: map['publicKey']?.toString(),
      accountId: map['accountId']?.toString(),
      encryptionKey:
          map['encryptionKey']?.toString() ?? map['encryption_key']?.toString(),
    );
  }
}

class PaymentResult {
  final bool success;
  final bool pending;
  final String? transactionId;
  final String? message;

  const PaymentResult({
    required this.success,
    required this.pending,
    this.transactionId,
    this.message,
  });

  const PaymentResult.success({String? transactionId, String? message})
    : success = true,
      pending = false,
      transactionId = transactionId,
      message = message;

  const PaymentResult.pending({String? transactionId, String? message})
    : success = false,
      pending = true,
      transactionId = transactionId,
      message = message;

  const PaymentResult.failed({String? transactionId, String? message})
    : success = false,
      pending = false,
      transactionId = transactionId,
      message = message;
}
