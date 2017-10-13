Shader "Kaima/Depth/SimpleBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurLevel("Blur Level", Float) = 1
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
				float2 uv[9] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurLevel;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv[0] = v.uv + _MainTex_TexelSize.xy * float2(-1, -1) * _BlurLevel;
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * float2(-1, 0) * _BlurLevel;
				o.uv[2] = v.uv + _MainTex_TexelSize.xy * float2(-1, 1) * _BlurLevel;
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * float2(0, -1) * _BlurLevel;
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * float2(0, 0) * _BlurLevel;
				o.uv[5] = v.uv + _MainTex_TexelSize.xy * float2(0, 1) * _BlurLevel;
				o.uv[6] = v.uv + _MainTex_TexelSize.xy * float2(1, -1) * _BlurLevel;
				o.uv[7] = v.uv + _MainTex_TexelSize.xy * float2(1, 0) * _BlurLevel;
				o.uv[8] = v.uv + _MainTex_TexelSize.xy * float2(1, 1) * _BlurLevel;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv[0]);
				col += tex2D(_MainTex, i.uv[1]);
				col += tex2D(_MainTex, i.uv[2]);
				col += tex2D(_MainTex, i.uv[3]);
				col += tex2D(_MainTex, i.uv[4]);
				col += tex2D(_MainTex, i.uv[5]);
				col += tex2D(_MainTex, i.uv[6]);
				col += tex2D(_MainTex, i.uv[7]);
				col += tex2D(_MainTex, i.uv[8]);
				col /= 9;
				return col;
			}
			ENDCG
		}
	}
}
