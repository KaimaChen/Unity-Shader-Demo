Shader "Kaima/PostProcessing/CrossHatching"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				const float threshold1 = 1.0;
				const float threshold2 = 0.7;
				const float threshold3 = 0.5;
				const float threshold4 = 0.3;
				const float offset = 5.0;

				fixed4 col = tex2D(_MainTex, i.uv);
				float lum = length(col.rgb);

				if(lum < threshold1)
					if((i.vertex.x + i.vertex.y) % 10 == 0)
						return fixed4(0,0,0,0);

				if(lum < threshold2)
					if((i.vertex.x - i.vertex.y) % 10 == 0)
						return fixed4(0,0,0,0);

				if(lum < threshold3)
					if((i.vertex.x + i.vertex.y - offset) % 10 == 0)
						return fixed4(0,0,0,0);

				if(lum < threshold4)
					if((i.vertex.x - i.vertex.y - offset) % 10 == 0)
						return fixed4(0,0,0,0);

				return fixed4(1,1,1,1);
			}
			ENDCG
		}
	}
}
