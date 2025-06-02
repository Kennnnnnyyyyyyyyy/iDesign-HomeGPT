import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req) => {
  try {
    const { imageUrl, filePath, prompt } = await req.json();

    console.log("📥 Received input:", { imageUrl, filePath, prompt });

    if (!imageUrl || !filePath || !prompt) {
      console.warn("⚠️ Missing required fields");
      return new Response(
        JSON.stringify({ error: "Missing imageUrl, filePath, or prompt" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const replicatePayload = {
      version: "76604baddc85b1b4616e1c6475eca080da339c8875bd4996705440484a6eac38",
      input: {
        image: imageUrl,
        prompt: prompt,
      },
    };

    console.log("📤 Sending to Replicate:", JSON.stringify(replicatePayload, null, 2));

    // Step 1: Call Replicate API
    const replicateResponse = await fetch("https://api.replicate.com/v1/predictions", {
      method: "POST",
      headers: {
        Authorization: `Token ${Deno.env.get("REPLICATE_API_TOKEN")}`,
        "Content-Type": "application/json",
        "Prefer": "wait",
      },
      body: JSON.stringify(replicatePayload),
    });

    const replicateResult = await replicateResponse.json();

    console.log("📥 Replicate response:", replicateResult);

    if (!replicateResponse.ok) {
      console.error("❌ Replicate API error:", replicateResult);
      return new Response(
        JSON.stringify({
          error: "Replicate call failed",
          details: replicateResult,
        }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Step 2: Delete the uploaded image from Supabase Storage
    const deleteUrl = `https://gmhaifyuoshptyxodvfm.supabase.co/storage/v1/object/temp-image/${filePath}`;
    console.log(`🗑️ Deleting from storage: ${deleteUrl}`);

    const deleteRes = await fetch(deleteUrl, {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
      },
    });

    if (!deleteRes.ok) {
      console.warn(`⚠️ Failed to delete file: ${filePath}`);
    } else {
      console.log(`✅ Successfully deleted: ${filePath}`);
    }

    // Step 3: Return the result from Replicate
    console.log("✅ Returning final result to client");
    return new Response(JSON.stringify(replicateResult), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });

  } catch (err) {
    console.error("❌ Unexpected Error:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
