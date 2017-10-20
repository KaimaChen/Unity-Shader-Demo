Shader "Kaima/Shape/Polygon"
{
	Properties
	{
		_Num("Num", Int) = 3
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

			int _Num;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 col = 0;
				float d = 0;

				i.uv = i.uv * 2 - 1;

				float a = atan2(i.uv.x, i.uv.y) + UNITY_PI;
				float r = (2 * UNITY_PI) / float(_Num);

				d = cos(floor(0.5 + a / r) * r - a) * length(i.uv);
				col = 1 - smoothstep(0.4, 0.41, d);

				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
