//简单的PBR：只考虑了方向光，并且把光源视作一个点，因此省略了积分
//基于Cook-Torrance BRDF
//参考https://learnopengl.com/#!PBR/Lighting
Shader "Kaima/PBS/SimplePBR"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range(0, 1)) = 1
		_Metallic("Metallic", Range(0, 1)) = 0.5
		// _Metallic("Metallic (R)", 2D) = "white" {}
		_Roughness("Roughness", Range(0, 1)) = 0.5
		// _AO("AO", 2D) = "white" {}
		_AO("AO", Range(0, 1)) = 0
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

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			sampler2D _MainTex;
			sampler2D _Normal;
			float _BumpScale;
			float _Metallic;
			// sampler2D _Metallic;
			float _Roughness;
			float _AO;
			// sampler2D _AO;

			float3 FresnelSchlick(float cosTheta, float3 F0)
			{
				return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
			}

			float DistributionGGX(float3 N, float3 H, float roughness)
			{
				float a = roughness * roughness;
				float a2 = a * a;
				float NdotH = saturate(dot(N, H));
				float NdotH2 = NdotH * NdotH;

				float nom = a2;
				float denom = (NdotH2 * (a2 - 1.0) + 1.0);
				denom = UNITY_PI * denom * denom;

				return nom / denom;
			}

			float GeometrySchlickGGX(float NdotV, float roughness)
			{
				float r = (roughness + 1.0);
				float k = (r * r) / 8.0;

				float nom = NdotV;
				float denom = NdotV * (1.0 - k) + k;

				return nom / denom;
			}

			float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
			{
				float NdotV = saturate(dot(N, V));
				float NdotL = saturate(dot(N, L));
				float ggx2 = GeometrySchlickGGX(NdotV, roughness);
				float ggx1 = GeometrySchlickGGX(NdotL, roughness);

				return ggx1 * ggx2;
			}

			float3 GetNormal(v2f i)
			{
				float3 N = UnpackNormal(tex2D(_Normal, i.uv));
				N.xy *= _BumpScale;
				N.z = sqrt(1.0 - saturate(dot(N.xy, N.xy)));
				N = normalize(half3(dot(i.TtoW0.xyz, N), dot(i.TtoW1.xyz, N), dot(i.TtoW2.xyz, N)));
				return N;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				float3 worldNormal = UnityObjectToWorldDir(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				// float metallic = tex2D(_Metallic, i.uv).r;
				float metallic = _Metallic;
				// float ao = tex2D(_AO, i.uv).r;
				float ao = _AO;

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 V = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 L = normalize(UnityWorldSpaceLightDir(worldPos)); 
				float3 N = GetNormal(i);
				float3 H = normalize(V + L);

				float3 F0 = float3(0.04, 0.04, 0.04);
				F0 = lerp(F0, albedo, metallic);

				float dist = length(_WorldSpaceLightPos0.xyz - worldPos);
				float attenuation = 1;
				float3 radiance = _LightColor0.rgb * attenuation;

				float HdotV = saturate(dot(H, V));
				float NdotV = saturate(dot(N, V));
				float NdotL = saturate(dot(N, L));

				//cook-torrance BRDF
				float NDF = DistributionGGX(N, H, _Roughness);
				float G = GeometrySmith(N, V, L, _Roughness);
				float3 F = FresnelSchlick(HdotV, F0);

				float3 kS = F;
				float3 kD = float3(1, 1, 1) - kS;
				kD *= 1.0 - metallic;

				float3 nominator = NDF * G * F;
				float denominator = 4 * NdotV * NdotL + 0.001; //0.001是为了避免除0
				float3 specular = nominator / denominator;

				float3 L0 = (kD * albedo / UNITY_PI + specular) * radiance * NdotL;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo * ao;

				fixed4 col = fixed4(ambient + L0, 1);
				return col;
			}
			ENDCG
		}
	}
}
