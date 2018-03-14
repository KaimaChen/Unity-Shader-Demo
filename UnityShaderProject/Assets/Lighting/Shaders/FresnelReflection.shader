Shader "Kaima/Lighting/FresnelReflection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FresnelScale("Fresnel Scale", Range(0, 1)) = 1
		_EnvMap("Env Map", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_forwardbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLightDir : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
				float3 worldReflect : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _FresnelScale;
			samplerCUBE _EnvMap;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldLightDir = UnityWorldSpaceLightDir(worldPos);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(i.worldLightDir);
				float3 worldViewDir = normalize(i.worldViewDir);
				float3 halfDir = normalize(i.worldLightDir + i.worldViewDir);
				fixed4 albedo = tex2D(_MainTex, i.uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldLightDir, worldNormal));
				fixed3 reflection = texCUBE(_EnvMap, i.worldReflect);
				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

				fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel));

				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
