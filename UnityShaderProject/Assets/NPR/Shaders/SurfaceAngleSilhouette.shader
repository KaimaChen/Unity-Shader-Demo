Shader "Kaima/NPR/Silhouette/SurfaceAngleSilhouette"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
		_Outline("Outline", Range(0, 1)) = 0.3
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

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			sampler2D _MainTex;
			float _Outline;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed3 SurfaceAngleSilhouette(float3 normal, float3 viewDir)
			{
				float edge = saturate(dot(normal, viewDir));
				edge = edge < _Outline ? edge / 4 : 1;
				return edge;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 edge = SurfaceAngleSilhouette(worldNormal, worldViewDir);

				fixed4 col = fixed4(edge, 1.0);
				return col;
			}
			ENDCG
		}
	}
}
