Shader "Kaima/Depth/DepthOfField"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Focus("Focus", Range(0, 1)) = 0
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
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _BlurTex;
			sampler2D _CameraDepthTexture;
			float _Focus;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, v.uv);
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0)
						o.uv.w = 1 - o.uv.w;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed4 blurCol = tex2D(_BlurTex, i.uv.zw);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				float linearDepth = Linear01Depth(depth);
				return lerp(col, blurCol, abs(linearDepth - _Focus) * 5);
			}
			ENDCG
		}
	}
}
