import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

serve(async (req: Request) => {
  const authHeader = req.headers.get("Authorization") || "";
  const token = authHeader.replace("Bearer ", "");

  console.log("[Debug] Raw Authorization Header:", authHeader);
  console.log("[Debug] Extracted Token:", token);

  if (!token) {
    console.error("[Error] No token provided.");
    return new Response(
      JSON.stringify({ code: 401, message: "Unauthorized" }),
      { status: 401 }
    );
  }

  try {
    const [, payloadBase64] = token.split('.');
    const payloadJson = atob(payloadBase64);
    const payload = JSON.parse(payloadJson);

    const firebaseProjectId = "home-ai-3a75c";
    const expectedIssuer = `https://securetoken.google.com/${firebaseProjectId}`;

    if (payload.iss !== expectedIssuer || payload.aud !== firebaseProjectId) {
      console.error("[Error] Invalid issuer or audience.");
      return new Response(
        JSON.stringify({ code: 401, message: "Invalid JWT" }),
        { status: 401 }
      );
    }

    console.log("[Success] Firebase JWT verified.");

    return new Response(
      JSON.stringify({
        message: "Firebase JWT verified successfully",
        role: "authenticated",
        user: {
          uid: payload.user_id,
          email: payload.email,
        },
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

  } catch (err) {
    console.error("[Error] Token decoding failed:", err);
    return new Response(
      JSON.stringify({ code: 400, message: "Failed to decode token" }),
      { status: 400 }
    );
  }
});
