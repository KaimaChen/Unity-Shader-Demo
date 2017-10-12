Shader "Kaima/Depth/EdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeThreshold("Edge Threshold", Range(0.01, 1)) = 0.001
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
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float _EdgeThreshold;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.uv;

				float2 uv = v.uv;
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0)
						uv.y = 1 - uv.y;
				#endif
				//Robers算子
				o.uv[1] = uv + _MainTex_TexelSize.xy * float2(-1, -1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * float2(-1, 1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * float2(1, -1);
				o.uv[4] = uv + _MainTex_TexelSize.xy * float2(1, 1);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv[0]);
				
				float sample1 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[1])));
				float sample2 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[2])));
				float sample3 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[3])));
				float sample4 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[4])));

				float edge = 1.0;
				//对角线的差异相乘
				edge *= abs(sample1 - sample4) < _EdgeThreshold ? 1.0 : 0.0;
				edge *= abs(sample2 - sample3) < _EdgeThreshold ? 1.0 : 0.0;

				return edge;
				// return lerp(0, col, edge); //描边
			}
			ENDCG
		}
	}
}