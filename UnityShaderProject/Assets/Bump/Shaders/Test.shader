Shader "Kaima/Bump/Test"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _HeightMap("Height Map", 2D) = "gray" {}
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _HeightMap;
			float4 _HeightMap_TexelSize;

			void InitFragNormal(inout v2f i)
			{
				float h = tex2D(_HeightMap, i.uv);
				i.normal = float3(0, h, 0);
				i.normal = normalize(i.normal);
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				InitFragNormal(i);

				float3 worldNormal = normalize(i.normal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0).xyz;
				fixed4 albedo = tex2D(_MainTex, i.uv);

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed4 finalColor = fixed4(diffuse, 1.0);
				return finalColor;
			}
			ENDCG
		}
	}
}
