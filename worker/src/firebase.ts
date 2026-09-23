import { SignJWT, importPKCS8 } from "jose";
import type { WorkerEnv } from "./env";
export class HttpError extends Error {
  constructor(
    public status: number,
    message: string,
    public code = "error",
  ) {
    super(message);
    this.name = "HttpError";
  }
}

let accessTokenCache:
  | {
      token: string;
      expiresAt: number;
    }
  | null = null;

function normalizePrivateKey(privateKey: string): string {
  return privateKey.replace(/\\n/g, "\n");
}

async function getFirebaseAccessToken(env: WorkerEnv): Promise<string> {
  if (
    accessTokenCache &&
    Date.now() < accessTokenCache.expiresAt - 60_000
  ) {
    return accessTokenCache.token;
  }

  const privateKeyPem = normalizePrivateKey(
    env.FIREBASE_SERVICE_ACCOUNT_PRIVATE_KEY,
  );

  const privateKey = await importPKCS8(privateKeyPem, "RS256");

  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.database",
  })
    .setProtectedHeader({
      alg: "RS256",
      typ: "JWT",
    })
    .setIssuer(env.FIREBASE_SERVICE_ACCOUNT_EMAIL)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(privateKey);

  const body = new URLSearchParams({
    grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
    assertion,
  });

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });

  if (!response.ok) {
    const errorText = await response.text();

    throw new Error(
      `Firebase OAuth token failed: HTTP ${response.status} ${errorText}`,
    );
  }

  const data = (await response.json()) as {
    access_token?: string;
    expires_in?: number;
  };

  if (!data.access_token) {
    throw new Error("Firebase OAuth response has no access token.");
  }

  const expiresIn = Number(data.expires_in ?? 3600);

  accessTokenCache = {
    token: data.access_token,
    expiresAt: Date.now() + expiresIn * 1000,
  };

  return data.access_token;
}

function databaseUrl(env: WorkerEnv, path = ""): string {
  const base = env.FIREBASE_DATABASE_URL.replace(/\/+$/, "");
  const cleanPath = path.replace(/^\/+/, "");

  if (!cleanPath) {
    return `${base}/.json`;
  }

  return `${base}/${cleanPath}.json`;
}

async function firebaseRequest(
  env: WorkerEnv,
  path: string,
  options: RequestInit = {},
): Promise<Response> {
  const accessToken = await getFirebaseAccessToken(env);

  const headers = new Headers(options.headers);

  headers.set("Authorization", `Bearer ${accessToken}`);
  headers.set("Content-Type", "application/json");

  const response = await fetch(databaseUrl(env, path), {
    ...options,
    headers,
  });

  if (!response.ok) {
    const errorText = await response.text();

    throw new Error(
      `Firebase RTDB request failed: HTTP ${response.status} ${errorText}`,
    );
  }

  return response;
}

export async function firebaseGet<T>(
  env: WorkerEnv,
  path: string,
): Promise<T | null> {
  const response = await firebaseRequest(env, path, {
    method: "GET",
  });

  const text = await response.text();

  if (!text || text === "null") {
    return null;
  }

  return JSON.parse(text) as T;
}

export async function firebasePut(
  env: Env,
  path: string,
  data: unknown,
): Promise<void> {
  await firebaseRequest(env, path, {
    method: "PUT",
    body: JSON.stringify(data),
  });
}

export async function firebasePatch(
  env: Env,
  path: string,
  data: Record<string, unknown>,
): Promise<void> {
  await firebaseRequest(env, path, {
    method: "PATCH",
    body: JSON.stringify(data),
  });
}

function clean(value: unknown): string {
  return value == null ? "" : String(value).trim();
}

export async function getOrder(
  env: Env,
  orderId: string,
  uid: string,
): Promise<Record<string, any>> {
  const order = await firebaseGet<Record<string, any>>(
    env,
    `orders/${orderId}`,
  );

  if (!order) {
    throw new HttpError(404, "Order not found.", "not-found");
  }

  if (clean(order.userId) !== uid) {
    throw new HttpError(
      403,
      "You do not have permission to access this order.",
      "permission-denied",
    );
  }

  if (clean(order.paymentStatus).toLowerCase() === "paid") {
    throw new HttpError(
      409,
      "This order has already been paid.",
      "already-paid",
    );
  }

  return order;
}

export async function updateOrderPayment(params: {
  env: Env;
  orderId: string;
  paymentStatus: string;
  transactionId?: string;
}): Promise<void> {
  const { env, orderId, paymentStatus, transactionId } = params;

  const order = await firebaseGet<Record<string, any>>(
    env,
    `orders/${orderId}`,
  );

  if (!order) {
    return;
  }

  const updatedAt = new Date().toISOString();

  const updates: Record<string, unknown> = {
    [`orders/${orderId}/paymentStatus`]: paymentStatus,
    [`orders/${orderId}/updatedAt`]: updatedAt,
  };

  if (transactionId) {
    updates[`orders/${orderId}/transactionId`] = transactionId;
  }

  if (order.userId) {
    updates[`users/${order.userId}/orders/${orderId}/paymentStatus`] =
      paymentStatus;

    updates[`users/${order.userId}/orders/${orderId}/updatedAt`] =
      updatedAt;

    if (transactionId) {
      updates[`users/${order.userId}/orders/${orderId}/transactionId`] =
        transactionId;
    }
  }

  // Firebase Realtime Database multi-location update.
  await firebasePatch(env, "", updates);
}