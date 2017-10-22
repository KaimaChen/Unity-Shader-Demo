//热视图（只是模拟，因为真的实现需要热量图）
Shader "Kaima/PostProcessing/ThermalVision"
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
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 colors[3] = { float3(0, 0, 1), float3(1,1,0), float3(1,0,0) };
				// float lum = (col.r + col.g + col.b) / 3;
				float lum = dot(float3(0.30, 0.59, 0.11), col.rgb);
				int index = lum < 0.5f ? 0 : 1;
				col.rgb = lerp(colors[index], colors[index+1], (lum - float(index)*0.5) / 0.5);

				return col;
			}
			ENDCG
		}
	}
}
