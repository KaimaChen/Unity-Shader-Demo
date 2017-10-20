Shader "Kaima/Shape/Flower"
{
	Properties
	{
		_Num("Num", Float) = 5
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

				float f = abs(cos(a)) * 0.5 + 0.3;
				float cir = Circle(float2(0.5, 0.5), 0.15, i.uv);
				float cir2 = Circle(float2(0.5, 0.5), 0.13, i.uv);

				//1 - cir保证花瓣的函数在中间圆之外执行，step(f, r) * step(r, f + 0.1)描边，(1 - step(f, r)) * fixed3(1, 0, 1)花瓣着色
				fixed3 col1 = (1 - cir) * (1 - (step(f, r) * step(r, f + 0.1) + (1 - step(f, r)) * fixed3(1, 0, 1)));
				fixed3 col2 = (1 - cir2) * cir * fixed3(1, 0, 1) + cir2 * fixed3(1, 0, 0);
				col = col1 + col2;
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
