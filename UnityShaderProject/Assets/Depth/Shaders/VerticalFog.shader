Shader "Kaima/Depth/VerticalFog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogDensity("Fog Density", Float) = 1
		_StartY("Start Y", Float) = 0
		_EndY("End Y", Float) = 10
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
				float4 frustumDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float4x4 _FrustumDir;
			fixed4 _FogColor;
			float _FogDensity;
			float _StartY;
			float _EndY;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, v.uv);
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0)
						o.uv.w = 1 - o.uv.w;
				#endif

				int ix = (int)o.uv.z;
				int iy = (int)o.uv.w;
				o.frustumDir = _FrustumDir[ix + 2 * iy];

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				float linearEyeDepth = LinearEyeDepth(depth);
				float3 worldPos = _WorldSpaceCameraPos + linearEyeDepth * i.frustumDir.xyz;

				float fogDensity = (worldPos.y - _StartY) / (_EndY - _StartY);
				fogDensity = saturate(fogDensity * _FogDensity);
				
				fixed3 finalColor = lerp(_FogColor, col, fogDensity).xyz;
				return fixed4(finalColor, 1.0);
			}
			ENDCG
		}
	}
}
