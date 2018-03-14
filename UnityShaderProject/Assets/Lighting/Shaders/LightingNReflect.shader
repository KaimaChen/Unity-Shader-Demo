Shader "Kaima/Lighting/LightingNReflect"
{
	Properties
	{
		_EnvMap("Env Map", CUBE) = "_skybox" {}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_ReflectColor("Reflect Color", Color) = (1,1,1,1)
		_ReflectAmount("Reflect Amount", Range(0, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM
			#pragma multi_compile_forwardbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldReflect : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldLightDir : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
			};

			samplerCUBE _EnvMap;
			fixed4 _MainColor;
			fixed4 _ReflectColor;
			float _ReflectAmount;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
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
				float3 halfDir = normalize(worldViewDir + worldLightDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _MainColor.rgb;

				fixed3 diffuse = _LightColor0.rgb * _MainColor.rgb * saturate(dot(worldLightDir, worldNormal));

				fixed3 reflection = texCUBE(_EnvMap, i.worldReflect) * _ReflectColor;
				fixed3 color = lerp(ambient + diffuse, reflection, _ReflectAmount);

				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
