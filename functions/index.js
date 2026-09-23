const crypto = require('crypto');
const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret, defineString } = require('firebase-functions/params');
const admin = require('firebase-admin');
const Stripe = require('stripe');

admin.initializeApp();
const db = admin.database();

// -----------------------------------------------------------------------------
// Firebase / app configuration
// -----------------------------------------------------------------------------
const APP_WEB_URL = defineString('APP_WEB_URL', {
  default: 'https://YOUR-WEB-DOMAIN.example.com',
});
const PAYMENT_FUNCTION_BASE_URL = defineString('PAYMENT_FUNCTION_BASE_URL', {
  default: 'https://us-central1-YOUR-FIREBASE-PROJECT.cloudfunctions.net',
});

// -----------------------------------------------------------------------------
// Stripe
// -----------------------------------------------------------------------------
const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_PUBLISHABLE_KEY = defineString('STRIPE_PUBLISHABLE_KEY', { default: '' });
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');

// -----------------------------------------------------------------------------
// PayFast Pakistan
// -----------------------------------------------------------------------------
const PAYFAST_MERCHANT_ID = defineSecret('PAYFAST_MERCHANT_ID');
const PAYFAST_SECURED_KEY = defineSecret('PAYFAST_SECURED_KEY');
const PAYFAST_API_BASE_URL = defineString('PAYFAST_API_BASE_URL', {
  default: 'https://ipguat.apps.net.pk/Ecommerce/api',
});
const PAYFAST_TOKEN_URL = defineString('PAYFAST_TOKEN_URL', {
  default: 'https://ipguat.apps.net.pk/Ecommerce/api/token',
});
const PAYFAST_TRANSACTION_URL = defineString('PAYFAST_TRANSACTION_URL', {
  default: 'https://ipguat.apps.net.pk/Ecommerce/api/Transaction/PostTransaction',
});
const PAYFAST_MERCHANT_NAME = defineString('PAYFAST_MERCHANT_NAME', {
  default: 'Velora',
});
const PAYFAST_SIGNATURE = defineString('PAYFAST_SIGNATURE', { default: '' });
const PAYFAST_SUCCESS_CODES = defineString('PAYFAST_SUCCESS_CODES', {
  default: '00,000,success,successful,completed,paid',
});

// -----------------------------------------------------------------------------
// XPay Pakistan
// -----------------------------------------------------------------------------
const XPAY_API_KEY = defineSecret('XPAY_API_KEY');
const XPAY_SIGNATURE_SECRET = defineSecret('XPAY_SIGNATURE_SECRET');
const XPAY_WEBHOOK_SECRET = defineSecret('XPAY_WEBHOOK_SECRET');
const XPAY_BASE_URL = defineString('XPAY_BASE_URL', {
  default: 'https://xstak-pay-stg.xstak.com',
});
const XPAY_PUBLIC_KEY = defineString('XPAY_PUBLIC_KEY', { default: '' });
const XPAY_ACCOUNT_ID = defineString('XPAY_ACCOUNT_ID', { default: '' });
const XPAY_WEB_CHECKOUT_URL = defineString('XPAY_WEB_CHECKOUT_URL', {
  default: '',
});

function requireAuth(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in.');
  }
  return request.auth.uid;
}

function clean(value) {
  return value == null ? '' : String(value).trim();
}

function getOrder(orderId, uid) {
  return db.ref(`orders/${orderId}`).get().then((snapshot) => {
    if (!snapshot.exists()) {
      throw new HttpsError('not-found', 'Order not found.');
    }

    const order = snapshot.val();
    if (clean(order.userId) !== uid) {
      throw new HttpsError('permission-denied', 'This order does not belong to you.');
    }

    if (clean(order.paymentStatus).toLowerCase() === 'paid') {
      throw new HttpsError('failed-precondition', 'This order is already paid.');
    }

    return order;
  });
}

async function updateOrderPayment({ orderId, paymentStatus, transactionId }) {
  const orderSnapshot = await db.ref(`orders/${orderId}`).get();
  if (!orderSnapshot.exists()) return;

  const order = orderSnapshot.val();
  const now = new Date().toISOString();
  const updates = {
    paymentStatus,
    updatedAt: now,
  };

  if (transactionId) {
    updates.transactionId = transactionId;
  }

  const updateMap = {};
  Object.entries(updates).forEach(([key, value]) => {
    updateMap[`orders/${orderId}/${key}`] = value;
    if (order.userId) {
      updateMap[`users/${order.userId}/orders/${orderId}/${key}`] = value;
    }
  });

  await db.ref().update(updateMap);
}

function stripeClient() {
  return new Stripe(STRIPE_SECRET_KEY.value());
}

function amountInMinorUnits(total, currency) {
  const code = clean(currency).toUpperCase();
  if (code === 'JPY' || code === 'KRW') return Math.round(Number(total));
  return Math.round(Number(total) * 100);
}

async function createStripeSession({ orderId, order, customer, platform, uid }) {
  const stripe = stripeClient();
  const amount = amountInMinorUnits(order.total, order.currency);
  const email = clean(customer?.email);

  if (platform === 'web') {
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [
        {
          price_data: {
            currency: clean(order.currency).toLowerCase(),
            product_data: {
              name: `Velora order ${orderId}`,
            },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      customer_email: email || undefined,
      metadata: {
        orderId,
        userId: uid,
      },
      success_url: `${APP_WEB_URL.value()}/#/orders?payment=success&orderId=${encodeURIComponent(orderId)}`,
      cancel_url: `${APP_WEB_URL.value()}/#/checkout?payment=cancelled&orderId=${encodeURIComponent(orderId)}`,
    });

    await updateOrderPayment({
      orderId,
      paymentStatus: 'pending',
      transactionId: session.id,
    });

    return {
      gateway: 'stripe',
      type: 'hosted_checkout',
      transactionId: session.id,
      checkoutUrl: session.url,
      publishableKey: STRIPE_PUBLISHABLE_KEY.value(),
    };
  }

  const paymentIntent = await stripe.paymentIntents.create({
    amount,
    currency: clean(order.currency).toLowerCase(),
    automatic_payment_methods: { enabled: true },
    receipt_email: email || undefined,
    metadata: {
      orderId,
      userId: uid,
    },
  });

  await updateOrderPayment({
    orderId,
    paymentStatus: 'pending',
    transactionId: paymentIntent.id,
  });

  return {
    gateway: 'stripe',
    type: 'payment_intent',
    transactionId: paymentIntent.id,
    clientSecret: paymentIntent.client_secret,
    publishableKey: STRIPE_PUBLISHABLE_KEY.value(),
  };
}

async function payFastToken() {
  const url = PAYFAST_TOKEN_URL.value();
  const candidates = [
    {
      merchant_id: PAYFAST_MERCHANT_ID.value(),
      secured_key: PAYFAST_SECURED_KEY.value(),
      grant_type: 'client_credentials',
    },
    {
      MERCHANT_ID: PAYFAST_MERCHANT_ID.value(),
      SECURED_KEY: PAYFAST_SECURED_KEY.value(),
      grant_type: 'client_credentials',
    },
  ];

  let response;
  let data;

  for (const payload of candidates) {
    const formBody = new URLSearchParams(payload).toString();
    response = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: formBody,
    });

    data = await response.json();
    if (response.ok) break;

    response = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(payload),
    });

    data = await response.json();
    if (response.ok) break;
  }
  if (!response.ok) {
    throw new Error(`PayFast token request failed: ${JSON.stringify(data)}`);
  }

  const token = clean(data.access_token || data.ACCESS_TOKEN || data.token || data.TOKEN);
  if (!token) {
    throw new Error(`PayFast token was not returned: ${JSON.stringify(data)}`);
  }

  return token;
}

async function createPayFastSession({ orderId, order, customer }) {
  const token = await payFastToken();
  const sid = crypto.randomUUID();
  const now = new Date().toISOString();

  await db.ref(`paymentSessions/payfast/${sid}`).set({
    orderId,
    token,
    expiresAt: Date.now() + 30 * 60 * 1000,
    createdAt: now,
  });

  await updateOrderPayment({
    orderId,
    paymentStatus: 'pending',
    transactionId: `payfast_${sid}`,
  });

  const checkoutUrl = `${PAYMENT_FUNCTION_BASE_URL.value()}/payfastCheckout?sid=${encodeURIComponent(sid)}`;

  return {
    gateway: 'payfast',
    type: 'hosted_checkout',
    transactionId: `payfast_${sid}`,
    checkoutUrl,
  };
}

async function xpayRequest(path, payload) {
  const body = JSON.stringify(payload);
  const signature = crypto
    .createHmac('sha256', XPAY_SIGNATURE_SECRET.value())
    .update(body)
    .digest('hex');

  const response = await fetch(`${XPAY_BASE_URL.value().replace(/\/$/, '')}${path}`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': XPAY_API_KEY.value(),
      'x-account-id': XPAY_ACCOUNT_ID.value(),
      'x-signature': signature,
    },
    body,
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(`XPay request failed: ${JSON.stringify(data)}`);
  }
  return data;
}

async function createXPaySession({ orderId, order, customer, platform }) {
  const amount = Number(Number(order.total).toFixed(2));
  const currency = clean(order.currency).toUpperCase();

  const customerName =
    clean(customer?.name) ||
    clean(order.shippingAddress?.fullName) ||
    'Velora Customer';
  const customerEmail = clean(customer?.email);
  const customerPhone =
    clean(customer?.phone) ||
    clean(order.shippingAddress?.phone);

  // XPay's payment-link API requires a customer name and either
  // an email or phone number.
  if (!customerEmail && !customerPhone) {
    throw new HttpsError(
      'invalid-argument',
      'XPay requires the customer email or phone number.',
    );
  }

  // -------------------------------------------------------------------------
  // WEB
  // -------------------------------------------------------------------------
  // Flutter Web uses XPay's hosted payment-link flow.
  if (platform === 'web') {
    const payload = {
      order: {
        id: orderId,
        currency,
        order_amount: amount,
      },
      customer: {
        name: customerName,
        email: customerEmail,
        phone: customerPhone,
      },
      metadata: {
        order_reference: orderId,
      },
      description: `Velora order ${orderId}`,
    };

    const data = await xpayRequest('/public/v1/payment/link', payload);
    const paymentLink = clean(
      data.payment_link ||
        data.paymentLink ||
        data.data?.payment_link ||
        data.data?.paymentLink,
    );

    if (!paymentLink) {
      throw new Error(
        `XPay did not return a payment link: ${JSON.stringify(data)}`,
      );
    }

    const checkoutUrl = /^https?:\/\//i.test(paymentLink)
      ? paymentLink
      : `https://${paymentLink}`;

    // A payment link is not the final payment-intent ID. The authoritative
    // transaction ID will be written when the XPay webhook/reverification
    // resolves the payment intent.
    const transactionId = `xpay_link_${orderId}`;

    await updateOrderPayment({
      orderId,
      paymentStatus: 'pending',
      transactionId,
    });

    return {
      gateway: 'xpay',
      type: 'hosted_checkout',
      transactionId,
      checkoutUrl,
    };
  }

  // -------------------------------------------------------------------------
  // ANDROID / IOS
  // -------------------------------------------------------------------------
  const payload = {
    amount,
    currency,
    payment_method_types: 'card',
    customer: {
      name: customerName,
      email: customerEmail,
      phone: customerPhone,
    },
    shipping: {
      address1: clean(order.shippingAddress?.address),
      city: clean(order.shippingAddress?.city),
      country: 'Pakistan',
      province: clean(order.shippingAddress?.province),
      zip: clean(order.shippingAddress?.postalCode),
      shipping_method: 'Standard',
    },
    metadata: {
      order_reference: orderId,
    },
  };

  const data = await xpayRequest('/public/v1/payment/intent', payload);
  const source = data.data || data.payment_intent || data.paymentIntent || data;

  const clientSecret = clean(
    source.pi_client_secret ||
      source.client_secret ||
      source.clientSecret ||
      data.pi_client_secret ||
      data.client_secret,
  );

  // XPay's payment-intent identifier is returned as `_id`.
  const paymentIntentId = clean(
    source._id ||
      source.pi_id ||
      source.payment_intent_id ||
      source.paymentIntentId ||
      source.id ||
      data._id ||
      data.pi_id ||
      data.payment_intent_id,
  );

  const encryptionKey = clean(
    source.encryptionKey ||
      source.encryption_key ||
      source.encryption_keys ||
      data.encryptionKey ||
      data.encryption_key,
  );

  if (!clientSecret || !paymentIntentId || !encryptionKey) {
    throw new Error(
      `XPay did not return the fields required by the Flutter Element: ${JSON.stringify(data)}`,
    );
  }

  await updateOrderPayment({
    orderId,
    paymentStatus: 'pending',
    transactionId: paymentIntentId,
  });

  return {
    gateway: 'xpay',
    type: 'payment_intent',
    transactionId: paymentIntentId,
    clientSecret,
    encryptionKey,
    publicKey: XPAY_PUBLIC_KEY.value(),
    accountId: XPAY_ACCOUNT_ID.value(),
  };
}

exports.createPaymentSession = onCall(
  {
    region: 'us-central1',
    secrets: [
      STRIPE_SECRET_KEY,
      PAYFAST_MERCHANT_ID,
      PAYFAST_SECURED_KEY,
      XPAY_API_KEY,
      XPAY_SIGNATURE_SECRET,
    ],
  },
  async (request) => {
    const uid = requireAuth(request);
    const gateway = clean(request.data?.gateway).toLowerCase();
    const platform = clean(request.data?.platform).toLowerCase();
    const orderId = clean(request.data?.orderId);
    const customer = request.data?.customer || {};

    if (!['stripe', 'payfast', 'xpay'].includes(gateway)) {
      throw new HttpsError('invalid-argument', 'Unsupported payment gateway.');
    }
    if (!orderId) {
      throw new HttpsError('invalid-argument', 'Order ID is required.');
    }

    const order = await getOrder(orderId, uid);

    if (gateway === 'stripe') {
      return createStripeSession({ orderId, order, customer, platform, uid });
    }

    if (gateway === 'payfast') {
      return createPayFastSession({ orderId, order, customer });
    }

    return createXPaySession({ orderId, order, customer, platform });
  },
);

async function retrieveXPayPaymentIntent(paymentIntentId) {
  const base = XPAY_BASE_URL.value().replace(/\/$/, '');
  const response = await fetch(
    `${base}/public/v1/payment/intent/details/${encodeURIComponent(paymentIntentId)}`,
    {
      method: 'GET',
      headers: {
        'x-api-key': XPAY_API_KEY.value(),
        'x-account-id': XPAY_ACCOUNT_ID.value(),
      },
    },
  );
  const data = await response.json();
  if (!response.ok) {
    throw new Error(`XPay retrieve failed: ${JSON.stringify(data)}`);
  }
  return data.data || data.payment_intent || data.paymentIntent || data;
}

function xpayStatus(data) {
  return clean(data.pi_status || data.status || data.payment_status).toLowerCase();
}

function xpayOrderReference(data) {
  const metadata = data.metadata || data.meta || {};
  return clean(
    data.order_reference ||
      metadata.order_reference ||
      metadata.orderReference ||
      data.orderReference,
  );
}

function responseLooksSuccessful(data) {
  const values = [
    data?.status,
    data?.transaction_status,
    data?.payment_status,
    data?.status_code,
    data?.code,
  ]
    .filter(Boolean)
    .map((value) => clean(value).toLowerCase());

  const success = PAYFAST_SUCCESS_CODES.value()
    .split(',')
    .map((value) => clean(value).toLowerCase())
    .filter(Boolean);

  return values.some((value) => success.includes(value));
}

async function verifyPayFastTransaction(transactionId, basketId, token) {
  const base = PAYFAST_API_BASE_URL.value().replace(/\/$/, '');
  const path = transactionId
    ? `/transaction/${encodeURIComponent(transactionId)}`
    : `/transaction/basket_id/${encodeURIComponent(basketId)}`;

  const response = await fetch(`${base}${path}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${token}`,
      'x-access-token': token,
    },
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(`PayFast status request failed: ${JSON.stringify(data)}`);
  }

  return data;
}

exports.verifyPayment = onCall(
  {
    region: 'us-central1',
    secrets: [
      STRIPE_SECRET_KEY,
      XPAY_API_KEY,
      XPAY_SIGNATURE_SECRET,
    ],
  },
  async (request) => {
    const uid = requireAuth(request);
    const orderId = clean(request.data?.orderId);
    const gateway = clean(request.data?.gateway).toLowerCase();
    const transactionId = clean(request.data?.transactionId);
    const order = await getOrder(orderId, uid);

    if (!['stripe', 'payfast', 'xpay'].includes(gateway)) {
      throw new HttpsError('invalid-argument', 'Unsupported payment gateway.');
    }

    if (gateway === 'stripe') {
      if (!transactionId) {
        return { status: 'pending', message: 'Stripe transaction ID is missing.' };
      }

      const stripe = stripeClient();
      const paymentIntent = await stripe.paymentIntents.retrieve(transactionId);
      const expectedAmount = amountInMinorUnits(order.total, order.currency);
      const paid =
        paymentIntent.status === 'succeeded' &&
        paymentIntent.metadata?.orderId === orderId &&
        paymentIntent.amount === expectedAmount &&
        paymentIntent.currency === clean(order.currency).toLowerCase();

      if (paid) {
        await updateOrderPayment({
          orderId,
          paymentStatus: 'paid',
          transactionId: paymentIntent.id,
        });
        return {
          status: 'paid',
          transactionId: paymentIntent.id,
          message: 'Stripe payment verified.',
        };
      }

      if (paymentIntent.status === 'processing') {
        return {
          status: 'pending',
          transactionId: paymentIntent.id,
          message: 'Stripe is still processing the payment.',
        };
      }

      if (['canceled', 'requires_payment_method'].includes(paymentIntent.status)) {
        await updateOrderPayment({
          orderId,
          paymentStatus: 'failed',
          transactionId: paymentIntent.id,
        });
        return {
          status: 'failed',
          transactionId: paymentIntent.id,
          message: `Stripe payment status: ${paymentIntent.status}`,
        };
      }

      return { status: 'pending', transactionId: paymentIntent.id };
    }

    if (gateway === 'xpay') {
      if (!transactionId || !transactionId.startsWith('xpay_pi_')) {
        return {
          status: 'pending',
          message: 'XPay payment intent ID is missing or not yet available.',
        };
      }

      const paymentIntent = await retrieveXPayPaymentIntent(transactionId);
      const expectedAmount = Number(Number(order.total).toFixed(2));
      const actualAmount = Number(
        paymentIntent.amount ?? paymentIntent.order_amount,
      );
      const expectedCurrency = clean(order.currency).toUpperCase();
      const actualCurrency = clean(paymentIntent.currency).toUpperCase();

      const paid =
        xpayStatus(paymentIntent) === 'succeeded' &&
        xpayOrderReference(paymentIntent) === orderId &&
        actualAmount === expectedAmount &&
        actualCurrency === expectedCurrency;

      if (paid) {
        await updateOrderPayment({
          orderId,
          paymentStatus: 'paid',
          transactionId: paymentIntent._id || transactionId,
        });
        return {
          status: 'paid',
          transactionId: paymentIntent._id || transactionId,
          message: 'XPay payment verified.',
        };
      }

      const status = xpayStatus(paymentIntent);
      if (['failed', 'canceled', 'cancelled', 'voided'].includes(status)) {
        await updateOrderPayment({
          orderId,
          paymentStatus: 'failed',
          transactionId: paymentIntent._id || transactionId,
        });
        return {
          status: 'failed',
          transactionId: paymentIntent._id || transactionId,
          message: `XPay status: ${status}`,
        };
      }

      return {
        status: 'pending',
        transactionId: paymentIntent._id || transactionId,
        message: `XPay status: ${status || 'pending'}`,
      };
    }

    // PayFast needs the transaction-status response from your merchant account.
    // We never mark an order paid from the browser alone.
    return {
      status: 'pending',
      transactionId: transactionId || null,
      message: 'PayFast verification is pending gateway confirmation.',
    };
  },
);

exports.stripeWebhook = onRequest(
  {
    region: 'us-central1',
    secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET],
  },
  async (req, res) => {
    const signature = req.headers['stripe-signature'];
    if (!signature) {
      res.status(400).send('Missing Stripe signature.');
      return;
    }

    let event;
    try {
      const stripe = stripeClient();
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        STRIPE_WEBHOOK_SECRET.value(),
      );
    } catch (error) {
      res.status(400).send(`Webhook signature verification failed: ${error.message}`);
      return;
    }

    try {
      if (event.type === 'payment_intent.succeeded') {
        const intent = event.data.object;
        const orderId = clean(intent.metadata?.orderId);
        if (orderId) {
          await updateOrderPayment({
            orderId,
            paymentStatus: 'paid',
            transactionId: intent.id,
          });
        }
      }

      if (event.type === 'payment_intent.payment_failed') {
        const intent = event.data.object;
        const orderId = clean(intent.metadata?.orderId);
        if (orderId) {
          await updateOrderPayment({
            orderId,
            paymentStatus: 'failed',
            transactionId: intent.id,
          });
        }
      }

      if (event.type === 'checkout.session.completed' || event.type === 'checkout.session.async_payment_succeeded') {
        const session = event.data.object;
        const orderId = clean(session.metadata?.orderId);
        if (orderId && session.payment_status === 'paid') {
          await updateOrderPayment({
            orderId,
            paymentStatus: 'paid',
            transactionId: clean(session.payment_intent) || session.id,
          });
        }
      }

      res.status(200).json({ received: true });
    } catch (error) {
      console.error('Stripe webhook processing error', error);
      res.status(500).send('Webhook processing failed.');
    }
  },
);

exports.payfastCheckout = onRequest(
  {
    region: 'us-central1',
    secrets: [
      PAYFAST_MERCHANT_ID,
      PAYFAST_SECURED_KEY,
    ],
  },
  async (req, res) => {
    const sid = clean(req.query.sid);
    if (!sid) {
      res.status(400).send('Missing checkout session.');
      return;
    }

    const snapshot = await db.ref(`paymentSessions/payfast/${sid}`).get();
    if (!snapshot.exists()) {
      res.status(404).send('Payment session not found.');
      return;
    }

    const session = snapshot.val();
    if (Number(session.expiresAt || 0) < Date.now()) {
      res.status(410).send('Payment session expired.');
      return;
    }

    const orderSnapshot = await db.ref(`orders/${session.orderId}`).get();
    if (!orderSnapshot.exists()) {
      res.status(404).send('Order not found.');
      return;
    }

    const order = orderSnapshot.val();
    const customerEmail = clean(req.query.email || order.customerEmail);
    const phone = clean(order.shippingAddress?.phone);
    const returnBase = PAYMENT_FUNCTION_BASE_URL.value();
    const successUrl = `${returnBase}/payfastCallback?sid=${encodeURIComponent(sid)}&status=success`;
    const failureUrl = `${returnBase}/payfastCallback?sid=${encodeURIComponent(sid)}&status=failure`;

    const fields = {
      CURRENCY_CODE: clean(order.currency || 'PKR'),
      MERCHANT_ID: PAYFAST_MERCHANT_ID.value(),
      MERCHANT_NAME: PAYFAST_MERCHANT_NAME.value(),
      TOKEN: session.token,
      BASKET_ID: clean(session.orderId),
      TXNAMT: Number(order.total || 0).toFixed(2),
      ORDER_DATE: new Date().toISOString().slice(0, 19).replace('T', ' '),
      SUCCESS_URL: successUrl,
      FAILURE_URL: failureUrl,
      CHECKOUT_URL: `${APP_WEB_URL.value()}/#/orders?payment=return&orderId=${encodeURIComponent(session.orderId)}`,
      CUSTOMER_EMAIL_ADDRESS: customerEmail,
      CUSTOMER_MOBILE_NO: phone,
      VERSION: '1.0',
      TXNDESC: `Velora order ${session.orderId}`,
      PROCCODE: '00',
      TRAN_TYPE: 'ECOM',
      STORE_ID: '',
      RECURRING_TXN: 'false',
    };

    if (PAYFAST_SIGNATURE.value()) {
      fields.SIGNATURE = PAYFAST_SIGNATURE.value();
    }

    const inputFields = Object.entries(fields)
      .filter(([, value]) => value !== '')
      .map(
        ([name, value]) =>
          `<input type="hidden" name="${escapeHtml(name)}" value="${escapeHtml(value)}">`,
      )
      .join('\n');

    const html = `<!doctype html>
<html><head><meta charset="utf-8"><title>PayFast</title></head>
<body>
  <p style="font-family:sans-serif">Redirecting to PayFast…</p>
  <form id="payfast" method="post" action="${escapeHtml(PAYFAST_TRANSACTION_URL.value())}">
    ${inputFields}
  </form>
  <script>document.getElementById('payfast').submit();</script>
</body></html>`;

    res.set('Content-Type', 'text/html; charset=utf-8').status(200).send(html);
  },
);

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

exports.payfastCallback = onRequest(
  {
    region: 'us-central1',
    secrets: [PAYFAST_MERCHANT_ID, PAYFAST_SECURED_KEY],
  },
  async (req, res) => {
    const sid = clean(req.query.sid);
    const status = clean(req.query.status).toLowerCase();
    const transactionId = clean(
      req.query.transaction_id || req.query.transactionId || req.query.TXNID,
    );

    const snapshot = await db.ref(`paymentSessions/payfast/${sid}`).get();
    if (!snapshot.exists()) {
      res.redirect(`${APP_WEB_URL.value()}/#/orders?payment=unknown`);
      return;
    }

    const session = snapshot.val();

    if (status === 'failure') {
      await updateOrderPayment({
        orderId: session.orderId,
        paymentStatus: 'failed',
        transactionId: transactionId || `payfast_${sid}`,
      });
    } else {
      try {
        const data = await verifyPayFastTransaction(
          transactionId,
          session.orderId,
          session.token,
        );
        if (responseLooksSuccessful(data)) {
          await updateOrderPayment({
            orderId: session.orderId,
            paymentStatus: 'paid',
            transactionId: transactionId || `payfast_${sid}`,
          });
        }
      } catch (error) {
        console.error('PayFast callback verification pending', error);
      }
    }

    res.redirect(
      `${APP_WEB_URL.value()}/#/orders?payment=${status || 'return'}&orderId=${encodeURIComponent(session.orderId)}`,
    );
  },
);

exports.xpayWebhook = onRequest(
  {
    region: 'us-central1',
    secrets: [XPAY_API_KEY, XPAY_SIGNATURE_SECRET, XPAY_WEBHOOK_SECRET],
  },
  async (req, res) => {
    const signature = clean(req.headers['x-signature']);
    if (!signature) {
      res.status(400).send('Missing XPay signature.');
      return;
    }

    let payload;
    try {
      payload = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
      const signed = JSON.stringify(payload);
      const expected = crypto
        .createHmac('sha256', XPAY_WEBHOOK_SECRET.value())
        .update(signed)
        .digest('hex');

      const a = Buffer.from(expected, 'utf8');
      const b = Buffer.from(signature, 'utf8');
      if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
        res.status(401).send('Invalid XPay signature.');
        return;
      }
    } catch (error) {
      res.status(400).send('Invalid XPay webhook payload.');
      return;
    }

    try {
      const serialized = JSON.stringify(payload);
      const matches = serialized.match(/xpay_pi_[A-Za-z0-9_-]+/g) || [];
      const paymentIntentId = clean(
        payload._id ||
          payload.pi_id ||
          payload.payment_intent_id ||
          payload.paymentIntentId ||
          matches[0],
      );

      if (paymentIntentId) {
        const paymentIntent = await retrieveXPayPaymentIntent(paymentIntentId);
        const orderId = xpayOrderReference(paymentIntent);
        const status = xpayStatus(paymentIntent);

        if (orderId && status === 'succeeded') {
          await updateOrderPayment({
            orderId,
            paymentStatus: 'paid',
            transactionId: paymentIntentId,
          });
        } else if (orderId && ['failed', 'canceled', 'cancelled'].includes(status)) {
          await updateOrderPayment({
            orderId,
            paymentStatus: 'failed',
            transactionId: paymentIntentId,
          });
        }
      }

      res.status(200).json({ received: true });
    } catch (error) {
      console.error('XPay webhook processing error', error);
      res.status(500).send('Webhook processing failed.');
    }
  },
);
