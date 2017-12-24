Shader "Kaima/Shape/LineSegment"
{
	Properties
	{
		_StartEnd("Start(XY) End(ZW)", Vector) = (0, 0.5, 0, 0)
		_Width("Width", Range(0, 1)) = 0.01
		_Antialias("Antialias Width", Range(0, 0.1)) = 0.001
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			// #include "Assets/_Libs/Tools.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float4 _StartEnd;
			float _Width;
			float _Antialias;

float LineSegment(float2 point1, float2 point2, float width, float aa, float2 uv)
{
	float smallerX = min(point1.x, point2.x);
	float biggerX = max(point1.x, point2.x);
	float smallerY = min(point1.y, point2.y);
	float biggerY = max(point1.y, point2.y);

	if(point1.x == point2.x) //避免下面的除0问题
	{
		return 1 - smoothstep(width/2.0, width/2.0+aa, abs(uv.x - point1.x));
	}

	float k = (point1.y - point2.y) / (point1.x - point2.x);
	float b = point1.y - k * point1.x;

	float d = abs(k * uv.x - uv.y + b) / sqrt(k * k + 1);
	float t = smoothstep(width/2.0, width/2.0 + aa, d);
	return (1.0 - t)  * step(smallerX, uv.x) * step(smallerY, uv.y) * step(biggerX, 1-uv.x);
}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return LineSegment(_StartEnd.xy, _StartEnd.zw, _Width, _Antialias, i.uv);               
			}
			ENDCG
		}
	}
}
