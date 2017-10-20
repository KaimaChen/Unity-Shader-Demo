Shader "Kaima/Shape/Gear" 
{
	Properties
	{
		_Num("Num", Float) = 2
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
			#include "Assets/_Libs/Tools.cginc"

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

			float _Num;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 col = 0;
				float2 pos = i.uv - 0.5; //[-0.5, 0.5]

				//Polar Coordinate
				float r = length(pos) * 2.0; //mul 2.0 just make it bigger
				float a = atan2(pos.y, pos.x) * _Num;

				float v1 = smoothstep(-0.5, 1.0, cos(a * 10)) * 0.2 + 0.5;
				float v2 = Circle(float2(0.5,0.5), 0.2, i.uv);
				float v3 = 1 - Circle(float2(0.5,0.5), 0.1, i.uv);

				col = step(v1, r) + v2 * v3;
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
