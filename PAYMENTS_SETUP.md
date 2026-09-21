# Velora — Stripe + PayFast Pakistan + XPay payment integration

This patch connects the checkout screen to three payment gateways while keeping gateway secrets on Firebase Cloud Functions.

## What changed

- COD still creates the order and immediately shows the success page.
- Online Payment now lets the customer choose Stripe, PayFast, or XPay.
- An online order is created first with `paymentStatus: pending`.
- Stripe Android/iOS uses Stripe PaymentSheet.
- Stripe web uses hosted Stripe Checkout, avoiding reliance on the experimental Flutter Stripe web UI for this flow.
- PayFast Pakistan uses a server-generated hosted form and opens it in the browser.
- XPay Android/iOS uses `xpay_element_flutter`.
- XPay web is intentionally adapter-based: the current Flutter XPay Element package is mobile-focused, so the web path expects either the merchant's XPay Web SDK or a hosted checkout URL/template.
- Paid status is written by trusted backend verification/webhooks instead of trusting the mobile/browser client.

## 1. Pubspec changes

Add:

```yaml
xpay_element_flutter: ^7.0.5
```

You already have:

```yaml
cloud_functions: ^6.4.0
firebase_database: ^12.5.0
url_launcher: ^6.3.2
flutter_stripe: ^13.0.0
flutter_stripe_web: ^8.0.0
```

For this Pakistan/PKR implementation, the existing `payfast` / `payfast_web` packages should not be used for PayFast Pakistan. They belong to a different PayFast integration ecosystem. The patch therefore implements Pakistan PayFast through its server API/hosted checkout instead.

Then run:

```bash
flutter pub get
```

## 2. Stripe mobile platform setup

The Stripe Flutter package documents iOS 13+ and requires the Android Stripe UI to run with an AppCompat theme / FragmentActivity setup.

### Android

Open `android/app/src/main/kotlin/.../MainActivity.kt` and make the activity extend `FlutterFragmentActivity` instead of `FlutterActivity` if your project still uses the standard activity:

```kotlin
package YOUR.PACKAGE.NAME

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

Use an AppCompat-based launch/app theme in `android/app/src/main/res/values/styles.xml` as required by your installed Stripe version.

### iOS

Set the deployment target to 13.0 in `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Then run:

```bash
cd ios
pod install
cd ..
```

## 3. Firebase Functions

Copy the generated `payment_backend/functions` directory to the Firebase project root as:

```text
functions/
```

Make sure `firebase.json` points to that directory:

```json
{
  "functions": {
    "source": "functions"
  }
}
```

Then:

```bash
cd functions
npm install
cd ..
```

## 4. Firebase secrets

Set only real merchant credentials in Secret Manager. Never put these in Flutter source, `--dart-define`, or a web bundle.

### Stripe

```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
```

The publishable key is a non-secret configuration value:

```text
STRIPE_PUBLISHABLE_KEY = pk_test_...   # test
STRIPE_PUBLISHABLE_KEY = pk_live_...   # production
```

### PayFast Pakistan

```bash
firebase functions:secrets:set PAYFAST_MERCHANT_ID
firebase functions:secrets:set PAYFAST_SECURED_KEY
```

### XPay Pakistan

```bash
firebase functions:secrets:set XPAY_API_KEY
firebase functions:secrets:set XPAY_SIGNATURE_SECRET
firebase functions:secrets:set XPAY_WEBHOOK_SECRET
```

Do not put the XPay API key/signature secret in Flutter.

## 5. Firebase parameter configuration

The functions use Firebase parameterized configuration. During deployment Firebase will prompt for these values, or you can configure them through your normal Firebase parameter workflow.

Required values:

```text
APP_WEB_URL
PAYMENT_FUNCTION_BASE_URL
STRIPE_PUBLISHABLE_KEY
PAYFAST_API_BASE_URL
PAYFAST_TOKEN_URL
PAYFAST_TRANSACTION_URL
PAYFAST_MERCHANT_NAME
PAYFAST_SIGNATURE          # only when your PayFast checkout contract requires one
PAYFAST_SUCCESS_CODES
XPAY_BASE_URL
XPAY_PUBLIC_KEY
XPAY_ACCOUNT_ID
XPAY_WEB_CHECKOUT_URL
```

For local/testing, use the UAT/test endpoints supplied by each gateway. Do not mix UAT credentials with live endpoints.

A typical `PAYMENT_FUNCTION_BASE_URL` looks like:

```text
https://us-central1-YOUR_FIREBASE_PROJECT.cloudfunctions.net
```

## 6. Stripe webhook

Create a webhook endpoint for:

```text
https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/stripeWebhook
```

Subscribe at minimum to:

```text
payment_intent.succeeded
payment_intent.payment_failed
checkout.session.completed
checkout.session.async_payment_succeeded
```

Use the signing secret from Stripe as `STRIPE_WEBHOOK_SECRET`.

## 7. XPay webhook

Create the webhook endpoint:

```text
https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/xpayWebhook
```

Configure your XPay webhook secret as `XPAY_WEBHOOK_SECRET`.

The function verifies the HMAC signature, retrieves the PaymentIntent server-side, checks the order reference, and only then updates the order as paid.

## 8. PayFast Pakistan

The PayFast checkout form is rendered by the Firebase HTTPS function so merchant credentials and the access token are never placed in the Flutter app.

The defaults in the generated function use the UAT `PostTransaction` example from PayFast's browser checkout documentation. Your merchant account may require a different token URL, transaction URL, signature value, processor code, or transaction type. Set the Firebase parameters to the exact values supplied for your PayFast environment before going live.

The callback intentionally keeps a successful payment as `pending` unless the transaction-status response matches `PAYFAST_SUCCESS_CODES`. This prevents the browser redirect alone from being treated as proof of payment.

## 9. XPay web limitation

The generated mobile XPay integration is complete around the Flutter Element flow, but the package used here is intended for Android/iOS. The web adapter therefore accepts `XPAY_WEB_CHECKOUT_URL`.

When your XPay merchant account provides a hosted web checkout URL/template, configure it with these placeholders:

```text
{ORDER_ID}
{AMOUNT}
```

Example shape:

```text
https://your-xpay-hosted-page.example/checkout?order={ORDER_ID}&amount={AMOUNT}
```

If your XPay account instead provides a JavaScript Web SDK, keep the same backend `createPaymentSession` / `verifyPayment` architecture and replace only `lib/services/xpay_service_web.dart` with the SDK bridge.

## 10. Order security — important

Your existing app has a customer-side `updatePaymentStatus()` repository method. Do not rely on that method for marking an order paid.

Your Realtime Database rules should prevent a customer from changing:

```text
paymentStatus
transactionId
```

for an order that they own. The payment functions in this patch use Firebase Admin privileges, verify the gateway response, and then update both:

```text
orders/{orderId}
users/{userId}/orders/{orderId}
```

## 11. Deploy

From the Firebase project root:

```bash
firebase deploy --only functions
```

Then build Flutter:

```bash
flutter clean
flutter pub get
flutter run
```

For web:

```bash
flutter build web
```

## 12. Testing order

Test gateways one at a time in UAT/test mode.

1. COD — order should become successful immediately.
2. Stripe mobile — PaymentSheet opens, then the backend verifies the PaymentIntent.
3. Stripe web — hosted Checkout opens, then the Stripe webhook marks the order paid.
4. XPay Android/iOS — XPay Element opens, then the backend verifies the PaymentIntent.
5. PayFast — browser checkout opens, then callback/status verification determines whether the order remains pending or becomes paid.

Never test the payment flow by manually editing `paymentStatus` in the client database.
