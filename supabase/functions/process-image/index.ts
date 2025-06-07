import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  try {
    const { imageUrl, filePath, prompt } = await req.json();
    console.log("📥 Received:", {
      imageUrl,
      filePath,
      prompt
    });
    if (!imageUrl || !filePath || !prompt) {
      return new Response(JSON.stringify({
        error: "Missing imageUrl, filePath, or prompt"
      }), {
        status: 400,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    // Step 1: Call Replicate
    const replicatePayload = {
      version: "76604baddc85b1b4616e1c6475eca080da339c8875bd4996705440484a6eac38",
      input: {
        image: imageUrl,
        prompt
      }
    };
    const replicateResponse = await fetch("https://api.replicate.com/v1/predictions", {
      method: "POST",
      headers: {
        Authorization: `Token ${Deno.env.get("REPLICATE_API_TOKEN")}`,
        "Content-Type": "application/json",
        Prefer: "wait"
      },
      body: JSON.stringify(replicatePayload)
    });
    const replicateResult = await replicateResponse.json();
    if (!replicateResponse.ok || !replicateResult.output) {
      console.error("❌ Replicate error:", replicateResult);
      return new Response(JSON.stringify({
        error: "Replicate failed",
        details: replicateResult
      }), {
        status: 500,
        headers: {
          "Content-Type": "application/json"
        }
      });
    }
    const replicateOutputUrl = replicateResult.output;
    console.log("🖼️ Replicate Output URL:", replicateOutputUrl);

    // ✅ DELETE the temp uploaded image from 'temp-image' bucket
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const deleteResult = await supabase.storage
      .from("temp-image")
      .remove([filePath]);

    if (deleteResult.error) {
      console.error("⚠️ Failed to delete temp image:", deleteResult.error);
    } else {
      console.log("🧹 Temp image deleted:", filePath);
    }
    // Step 2: Return Replicate output URL
    return new Response(JSON.stringify({
      replicateOutputUrl,
      filePath,
      prompt
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    console.error("❌ Unexpected error:", err);
    return new Response(JSON.stringify({
      error: "Internal Server Error"
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
