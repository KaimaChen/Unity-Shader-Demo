Shader "Kaima/Other/BlackHole"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RightX("Right X", Float) = 0
		_LeftX("Left X", Float) = 0
		_Control("Born Control", Range(0, 2)) = 0
		_BlackHolePos("Black Hole Position", Vector) = (1,1,1,1)
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
			float _RightX;
			float _LeftX;
			float _Control;
			float4 _BlackHolePos;

			float GetNormalizedDist(float worldPosX)
			{
				float range = _RightX - _LeftX;
				float border = _RightX;

				float dist = abs(worldPosX - border);
				float normalizedDist = saturate(dist / range);
				return normalizedDist;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 toBlackHole = mul(unity_WorldToObject, (_BlackHolePos - worldPos)).xyz;
				float normalizedDist = GetNormalizedDist(worldPos.x);
				float val = max(0, _Control - normalizedDist);
				v.vertex.xyz += toBlackHole * val;

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				clip(_BlackHolePos.x - i.worldPos.x);
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
