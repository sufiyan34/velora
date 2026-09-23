import {
  decodeProtectedHeader,
  importX509,
  jwtVerify,
} from "jose";
import type { WorkerEnv } from "./env";
const FIREBASE_CERTS_URL =
  "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com";

type FirebaseCerts = Record<string, string>;

let certCache:
  | {
      certs: FirebaseCerts;
      expiresAt: number;
    }
  | null = null;

export class AuthError extends Error {
  status = 401;

  constructor(message: string) {
    super(message);
    this.name = "AuthError";
  }
}

async function fetchFirebaseCerts(): Promise<FirebaseCerts> {
  const response = await fetch(FIREBASE_CERTS_URL);

  if (!response.ok) {
    throw new Error(
      `Unable to fetch Firebase public keys: HTTP ${response.status}`,
    );
  }

  const certs = (await response.json()) as FirebaseCerts;

  const cacheControl =
    response.headers.get("cache-control") ?? "";

  const match = cacheControl.match(/max-age=(\d+)/);

  const maxAgeMs = match
    ? Number(match[1]) * 1000
    : 60 * 60 * 1000;

  certCache = {
    certs,
    expiresAt: Date.now() + maxAgeMs,
  };

  return certs;
}

async function getFirebaseCertificate(
  kid: string,
): Promise<CryptoKey> {
  let certs: FirebaseCerts;

  if (certCache && Date.now() < certCache.expiresAt) {
    certs = certCache.certs;
  } else {
    certs = await fetchFirebaseCerts();
  }

  // Firebase signing keys can rotate.
  // Refresh once if the requested key isn't cached.
  if (!certs[kid]) {
    certs = await fetchFirebaseCerts();
  }

  const certificate = certs[kid];

  if (!certificate) {
    throw new AuthError(
      "Firebase signing key not found.",
    );
  }

  return importX509(certificate, "RS256");
}

export async function verifyFirebaseIdToken(
  request: Request,
 env: WorkerEnv,
): Promise<string> {
  const authorization =
    request.headers.get("Authorization");

  if (!authorization?.startsWith("Bearer ")) {
    throw new AuthError(
      "Missing Firebase Authorization token.",
    );
  }

  const token = authorization
    .substring(7)
    .trim();

  if (!token) {
    throw new AuthError(
      "Missing Firebase ID token.",
    );
  }

  let header;

  try {
    header = decodeProtectedHeader(token);
  } catch {
    throw new AuthError(
      "Invalid Firebase ID token.",
    );
  }

  if (!header.kid) {
    throw new AuthError(
      "Firebase ID token has no signing key.",
    );
  }

  const publicKey =
    await getFirebaseCertificate(header.kid);

  try {
    const { payload } = await jwtVerify(
      token,
      publicKey,
      {
        algorithms: ["RS256"],
        issuer:
          `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`,
        audience: env.FIREBASE_PROJECT_ID,
      },
    );

    if (
      typeof payload.sub !== "string" ||
      !payload.sub
    ) {
      throw new AuthError(
        "Firebase token has no valid user ID.",
      );
    }

    if (typeof payload.auth_time !== "number") {
      throw new AuthError(
        "Firebase token has no valid auth time.",
      );
    }

    return payload.sub;
  } catch (error) {
    if (error instanceof AuthError) {
      throw error;
    }

    throw new AuthError(
      "Invalid or expired Firebase ID token.",
    );
  }
}