Shader "Kaima/Lighting/Fresnel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EnvMap("Environment Map", Cube) = "_Skybox" {}
		_FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

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
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
				float3 worldReflect : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			samplerCUBE _EnvMap;
			float _FresnelScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(i.worldViewDir);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 reflectColor = texCUBE(_EnvMap, i.worldReflect);

				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
				fresnel = saturate(fresnel);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * col.rgb;
				fixed3 diffuse = _LightColor0.rgb * col.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 result = ambient + lerp(diffuse, reflectColor, fresnel);

				return fixed4(result, 1);
			}
			ENDCG
		}
	}
}
