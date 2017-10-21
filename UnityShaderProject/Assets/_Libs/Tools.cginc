#ifndef TOOLS_INCLUDED
#define TOOLS_INCLUDED

// Function from the book of shaders
// https://thebookofshaders.com/06/
float3 RGB2HSB(in float3 c)
{
	float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = lerp(float4(c.bg, K.wz),
			float4(c.gb, K.xy),
			step(c.b, c.g));
	float4 q = lerp(float4(p.xyw, c.r),
			float4(c.r, p.yzx),
			step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
			d / (q.x + e),
			q.x);
}

//  Function from Iñigo Quiles 
//  https://www.shadertoy.com/view/MsS3Wc
float3 HSB2RGB(in float3 c)
{
	float3 v = float3(c.x * 6.0, c.x * 6.0, c.x * 6.0);
	float3 rgb = clamp(abs(((v + float3(0.0, 4.0, 2.0)) % 6.0) - 3.0) - 1.0, 0.0, 1.0);
	rgb = rgb * rgb * (3.0 - 2.0 * rgb);
	return c.z * lerp(float3(1.0, 1.0, 1.0), rgb, c.y);
}

float Circle(float2 center, float radius, float2 uv)
{
	float dist = distance(center, uv);
	return 1 - step(radius, dist);
}

float SmoothCircle(float2 center, float radius, float smoothWidth, float2 uv)
{
	float dist = distance(center, uv);
	return 1 - smoothstep(radius, radius + smoothWidth, dist);
}

#endif