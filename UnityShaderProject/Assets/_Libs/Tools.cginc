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

float Luminance(in float3 c)
{
	//根据人眼对颜色的敏感度，可以看见对绿色是最敏感的
	return 0.2125 * c.r + 0.7154 * c.g + 0.0721 * c.b;
}

float2 CorrectUV(in float2 uv, in float4 texelSize)
{
	float2 result = uv;
	
	#if UNITY_UV_STARTS_AT_TOP
	if(texelSize.y < 0.0)
		result.y = 1.0 - uv.y;
	#endif

	return result;
}

//value: [0, 1]
float Convert01(in float value)
{
	return (value * 0.5 + 0.5);
}

float Point(float2 position, float size, float2 uv)
{
	float2 v = 1 - step(size / 2.0, abs(uv - position.xy));
	return v.x * v.y;
}

float Line(float2 point1, float2 point2, float width, float aa, float2 uv)
{
	if(point1.x == point2.x) //避免下面的除0问题
	{
		return 1 - smoothstep(width/2.0, width/2.0+aa, abs(uv.x - point1.x));
	}

	float k = (point1.y - point2.y) / (point1.x - point2.x);
	float b = point1.y - k * point1.x;

	float d = abs(k * uv.x - uv.y + b) / sqrt(k * k + 1);
	float t = smoothstep(width/2.0, width/2.0 + aa, d);
	return 1.0 - t;
}

float LineSegment(float2 point1, float2 point2, float width, float smooth, float2 uv)
{
	float smallerX = min(point1.x, point2.x);
	float biggerX = max(point1.x, point2.x);
	float smallerY = min(point1.y, point2.y);
	float biggerY = max(point1.y, point2.y);

	if(point1.x == point2.x) //避免下面的除0问题
	{
		if(uv.y < smallerY || uv.y > biggerY) 
			return 0;

		return 1 - smoothstep(width/2.0, width/2.0+smooth, abs(uv.x - point1.x));
	}
	else if(point1.y == point2.y)
	{
		if(uv.x < smallerX || uv.x > biggerX)
			return 0;
	}
	else 
	{
		if(uv.x < smallerX || uv.x > biggerX || uv.y < smallerY || uv.y > biggerY)
			return 0;
	}

	float k = (point1.y - point2.y) / (point1.x - point2.x);
	float b = point1.y - k * point1.x;

	float d = abs(k * uv.x - uv.y + b) / sqrt(k * k + 1);
	float t = smoothstep(width/2.0, width/2.0 + smooth, d);
	return 1.0 - t;
}

//border : (left, right, bottom, top), all should be [0, 1]
float Rect(float4 border, float2 uv)
{
	float v1 = step(border.x, uv.x);
	float v2 = step(border.y, 1 - uv.x);
	float v3 = step(border.z, uv.y);
	float v4 = step(border.w, 1 - uv.y);
	return v1 * v2 * v3 * v4;
}

float SmoothRect(float4 border, float2 uv)
{
	float v1 = smoothstep(0, border.x, uv.x);
	float v2 = smoothstep(0, border.y, 1 - uv.x);
	float v3 = smoothstep(0, border.z, uv.y);
	float v4 = smoothstep(0, border.w, 1 - uv.y);
	return v1 * v2 * v3 * v4;
}

float Circle(float2 center, float radius, float2 uv)
{
	return 1 - step(radius, distance(uv, center));
}

float SmoothCircle(float2 center, float radius, float smoothWidth, float2 uv)
{
	return 1 - smoothstep(radius - smoothWidth, radius, distance(uv, center));
}

//y = kx 方程
float Equation(float2 uv, float kx)
{
	return smoothstep(kx - 0.01, kx, uv.y) - smoothstep(kx, kx + 0.01, uv.y);
}

#endif