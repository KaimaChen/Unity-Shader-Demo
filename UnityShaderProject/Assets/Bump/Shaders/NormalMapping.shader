Shader "Kaima/Bump/NormalMapping"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
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
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float2 uvNormal : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			
			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uvNormal = TRANSFORM_TEX(v.texcoord, _NormalMap);

				// float3 binormal = cross(v.normal, v.tangent) * v.tangent.w;
				// float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal); //本地到切空间
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(unity_WorldToObject, _WorldSpaceLightPos0).xyz;
				o.lightDir = mul(rotation, o.lightDir);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				float4 packedNormal = tex2D(_NormalMap, i.uvNormal);
				float3 normal = UnpackNormal(packedNormal);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
				fixed3 diffuse = albedo.rgb * _LightColor0.rgb * saturate(dot(normal, i.lightDir));

				fixed4 finalColor = fixed4(ambient + diffuse, 1.0);
				return finalColor;
			}
			ENDCG
		}
	}
}
