Shader "Kaima/NPR/Toon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Ramp("Ramp", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(0, 1)) = 0.2
		_ZOffset("Z Offset", Float) = -0.5
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularThreshold("Specular Threshold", Range(0, 1)) = 0.4
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		UsePass "Kaima/NPR/Silhouette/ProceduralGeometrySilhouette-VertexNormal/OUTLINE"

		Pass
		{
			NAME "TOON"
			Tags { "LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fdwbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "Assets/_Libs/Tools.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Ramp;
			float4 _Ramp_ST;
			fixed4 _SpecularColor;
			float _SpecularThreshold;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 halfDir = normalize(worldLightDir + worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;

				fixed diff = Convert01(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * tex2D(_Ramp, float2(diff, diff)).rgb; //访问渐变纹理来让漫反射部分是明暗变化的

				fixed spec = dot(worldNormal, halfDir);
				//简单实现，但锯齿明显
				// fixed3 specular = _SpecularColor.rgb * albedo.rgb * step(0, spec - _SpecularThreshold);
				//光滑实现
				// fixed w = 0.01; //w取一个很小的值即可
				fixed w = fwidth(spec) * 2.0;
				fixed3 specular = _SpecularColor.rgb * albedo.rgb * smoothstep(-w, w, spec - _SpecularThreshold);

				fixed4 result = fixed4(ambient + diffuse + specular, 1);
				return result;
			}
			ENDCG
		}
	}
}
