import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  const { style_image, structure_image } = await req.json()

  const replicateRes = await fetch('https://api.replicate.com/v1/predictions', {
    method: 'POST',
    headers: {
      'Authorization': `Token ${Deno.env.get("REPLICATE_API_TOKEN")}`,
      'Content-Type': 'application/json',
      'Prefer': 'wait'
    },
    body: JSON.stringify({
      version: 'f1023890703bc0a5a3a2c21b5e498833be5f6ef6e70e9daf6b9b3a4fd8309cf0',
      input: {
        style_image,
        structure_image,
        prompt: "Make the structure image inspired by style image, keeping the room layout but applying color tones, lighting, and textures from the style image.",
        output_format: 'png'
      }
    })
  })

  const result = await replicateRes.json()
  return new Response(JSON.stringify(result), {
    headers: { 'Content-Type': 'application/json' }
  })
})
