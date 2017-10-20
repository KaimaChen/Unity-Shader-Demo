Shader "Kaima/Shape/Polar1"
{
	Properties
	{
		_Num("Num", Float) = 10
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
				float2 pos = i.uv - 0.5; //[-0.5, 0.5], make (0,0) in the center

				float a = atan2(pos.y, pos.x) * _Num;
				// float a = atan2(pos.y, pos.x) * _Time.y; //Increase Animation
				// float a = atan2(pos.y, pos.x) * _Num + _Time.w; //Rotate Animation

				float f = cos(a);

				col = f;
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
