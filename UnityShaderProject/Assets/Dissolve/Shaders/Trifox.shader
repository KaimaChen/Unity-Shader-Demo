Shader "Kaima/Dissolve/Trifox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_DissolveThreshold("Dissolve Threshold", Range(0.0, 1.0)) = 0.5
		_PlayerToCameraDistance("Player To Camera Distance", Float) = 0
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
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uvMainTex : TEXCOORD0;
				float2 uvNoiseTex : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float2 tangentUV : TEXCOORD3;
				float4 screenPos : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _DissolveThreshold;
			float _PlayerToCameraDistance;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);

				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3 worldBinormal = normalize(mul(binormal, (float3x3)unity_WorldToObject));
				float3 worldTangent = normalize(mul(v.tangent.xyz, (float3x3)unity_WorldToObject));
				float x = dot(o.worldPos.xyz, worldBinormal);
				float y = dot(o.worldPos.xyz, worldTangent);
				o.tangentUV = float2(x, y);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float distanceToCamera = distance(i.worldPos.xyz, _WorldSpaceCameraPos.xyz);

				float2 wcoord = (i.screenPos.xy / i.screenPos.w);
				float distanceToScreenCenter = distance(wcoord, float2(0.5, 0.5));
				
				float cutout = tex2D(_NoiseTex, i.tangentUV);
				clip(cutout - _DissolveThreshold);

				float4 albedo = tex2D(_MainTex, i.uvMainTex);

				return albedo;
			}
			ENDCG
		}
	}
}
