// supabase/functions/store-replicate-image/index.ts

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  try {
    const { imageUrl } = await req.json();

    if (!imageUrl) {
      return new Response(JSON.stringify({ error: "Missing imageUrl" }), {
        status: 400,
      });
    }

    const fileName = `replicate_output_${Date.now()}.png`;

    const imageRes = await fetch(imageUrl);
    if (!imageRes.ok) {
      return new Response(
        JSON.stringify({ error: "Failed to fetch replicate image" }),
        { status: 500 }
      );
    }

    const imageBuffer = await imageRes.arrayBuffer();

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { error } = await supabaseClient.storage
      .from("ai-output")
      .upload(fileName, imageBuffer, {
        contentType: "image/png",
        upsert: true,
      });

    if (error) {
      console.error("Upload error:", error.message);
      return new Response(JSON.stringify({ error: "Upload failed" }), {
        status: 500,
      });
    }

    const publicUrl = `${Deno.env.get("SUPABASE_URL")}/storage/v1/object/public/aioutput//${fileName}`;

    return new Response(JSON.stringify({ publicUrl }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
    });
  }
});
