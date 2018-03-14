Shader "Kaima/Lighting/Reflect"
{
	Properties
	{
		_EnvMap("Environment Map", Cube) = "_Skybox" {}
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldReflect : TEXCOORD1;
				float3 localPos : TEXCOORD2;
			};

			samplerCUBE _EnvMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.worldReflect = reflect(-worldViewDir, worldNormal);
				o.localPos = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 reflectColor = texCUBE(_EnvMap, i.worldReflect);
				// fixed4 reflectColor = texCUBE(_EnvMap, i.localPos);
				return reflectColor;
			}
			ENDCG
		}
	}
}
