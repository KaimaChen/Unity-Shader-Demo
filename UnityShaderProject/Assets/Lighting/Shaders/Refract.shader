Shader "Kaima/Lighting/Refract"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EnvMap("Environment Map", Cube) = "_Skybox" {}
		_RefractRatio("Refract Ratio", Range(0, 1)) = 1
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldRefract : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			samplerCUBE _EnvMap;
			float _RefractRatio;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldNormal = UnityObjectToWorldDir(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.worldRefract = refract(-normalize(worldViewDir), normalize(worldNormal), _RefractRatio);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = texCUBE(_EnvMap, i.worldRefract);
				return col;
			}
			ENDCG
		}
	}
}
