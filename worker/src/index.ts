import { verifyFirebaseIdToken, AuthError } from "./auth";
import {
  HttpError,
  firebaseGet,
} from "./firebase";
import type { WorkerEnv } from "./env";

function corsHeaders(): HeadersInit {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods":
      "GET, POST, PUT, PATCH, DELETE, OPTIONS",
    "Access-Control-Allow-Headers":
      "Authorization, Content-Type",
  };
}

function jsonResponse(
  data: unknown,
  status = 200,
): Response {
  return Response.json(data, {
    status,
    headers: corsHeaders(),
  });
}

export default {
  async fetch(
    request: Request,
    env: WorkerEnv,
  ): Promise<Response> {
    const url = new URL(request.url);

    // CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(),
      });
    }

    try {
      // Health check
      if (
        request.method === "GET" &&
        url.pathname === "/health"
      ) {
        return jsonResponse({
          success: true,
          service: "Velora Payment Worker",
          status: "running",
          timestamp: new Date().toISOString(),
        });
      }

      // Temporary Firebase authentication test
      if (
        request.method === "POST" &&
        url.pathname === "/api/test-auth"
      ) {
        const uid = await verifyFirebaseIdToken(
          request,
          env,
        );

        return jsonResponse({
          success: true,
          message:
            "Firebase authentication successful.",
          uid,
        });
      }

      // Temporary Firebase RTDB test
      if (
        request.method === "POST" &&
        url.pathname === "/api/test-database"
      ) {
        const uid = await verifyFirebaseIdToken(
          request,
          env,
        );

        const body = (await request.json()) as {
          orderId?: string;
        };

        const orderId = body.orderId?.trim();

        if (!orderId) {
          throw new HttpError(
            400,
            "orderId is required.",
            "invalid-argument",
          );
        }

        const order =
          await firebaseGet<Record<string, any>>(
            env,
            `orders/${orderId}`,
          );

        if (!order) {
          throw new HttpError(
            404,
            "Order not found.",
            "not-found",
          );
        }

        if (
          String(order.userId ?? "").trim() !== uid
        ) {
          throw new HttpError(
            403,
            "You do not own this order.",
            "permission-denied",
          );
        }

        return jsonResponse({
          success: true,
          message:
            "Firebase RTDB access successful.",
          uid,
          order,
        });
      }

      // Root endpoint
      if (
        request.method === "GET" &&
        url.pathname === "/"
      ) {
        return jsonResponse({
          success: true,
          service: "Velora Payment Worker",
          message: "Worker is running",
        });
      }

      // Endpoint not found
      return jsonResponse(
        {
          success: false,
          error: "Endpoint not found",
        },
        404,
      );
    } catch (error) {
      console.error(error);

      if (error instanceof AuthError) {
        return jsonResponse(
          {
            success: false,
            error: error.message,
          },
          error.status,
        );
      }

      if (error instanceof HttpError) {
        return jsonResponse(
          {
            success: false,
            error: error.message,
            code: error.code,
          },
          error.status,
        );
      }

      return jsonResponse(
        {
          success: false,
          error:
            error instanceof Error
              ? error.message
              : "Internal server error",
        },
        500,
      );
    }
  },
};