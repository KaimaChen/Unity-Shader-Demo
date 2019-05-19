// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Kaima/Other/BornFromY"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TopY("Top Y", Float) = 0
		_BottomY("Bottom Y", Float) = 0
		_Control("Born Control", Range(0, 2)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _TopY;
			float _BottomY;
			float _Control;

			float GetNormalizedDist(float worldPosY)
			{
				float range = _TopY - _BottomY;
				float border = _TopY;

				float dist = abs(worldPosY - border);
				float normalizedDist = saturate(dist / range);
				return normalizedDist;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 localPositiveY = mul(unity_WorldToObject, float4(0, 1, 0, 1)).xyz;
				float normalizedDist = GetNormalizedDist(worldPos.y);
				float val = max(0, _Control - normalizedDist);
				v.vertex.xyz += localPositiveY * val;

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				clip(_TopY - i.worldPos.y);
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
