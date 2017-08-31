Shader "Kaima/Dissolve/DirectionAsh"
{
	Properties
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		[NoScaleOffset] _NoiseTex("Noise", 2D) = "white" {}
		[NoScaleOffset] _WhiteNoiseTex("White Noise", 2D) = "white" {}
		[NoScaleOffset] _RampTex("Border Ramp", 2D) = "white" {} //纹理要Clamp
		_EdgeWidth("Edge Width", Range(0.05, 0.2)) = 0.1
		_MinBorderY("Min Border Y", Float) = -0.5 //通常对应脚部Y坐标
		_MaxBorderY("Max Border Y", Float) = 0.5  //通常对应头部Y坐标
		_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5

		_AshColor("Ash Color", Color) = (1,1,1,1)
		_AshWidth("[Ash Width", Range(0, 0.25)) = 0.1
		_FlyIntensity("Fly Intensity", Range(0,0.3)) = 0.1
		_AshDensity("Ash Density", Range(0, 1)) = 1
		_FlyDirection("Fly Direction", Vector) = (1,1,1,1) 

		_Threshold("Threshold", Range(0.0, 1.0)) = 0.5
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }

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
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvMainTex : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			sampler2D _WhiteNoiseTex;
			fixed4 _AshColor;
			float _Threshold;
			float _EdgeWidth;
			sampler2D _RampTex;
			float _MinBorderY;
			float _MaxBorderY;
			float _DistanceEffect;
			float _AshWidth;
			float _FlyIntensity;
			float _AshDensity;
			float4 _FlyDirection;

			float GetNormalizedDist(float worldPosY)
			{
				float range = _MaxBorderY - _MinBorderY;
				float border = _MaxBorderY;

				float dist = abs(worldPosY - border);
				float normalizedDist = saturate(dist / range);
				return normalizedDist;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				float cutout = GetNormalizedDist(o.worldPos.y);
				float3 localFlyDirection = normalize(mul(unity_WorldToObject, _FlyDirection.xyz));
				float flyDegree = (_Threshold - cutout)/_EdgeWidth;
				float val = max(0, flyDegree * _FlyIntensity);
				v.vertex.xyz += localFlyDirection * val;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uvMainTex);
				float commonNoise = tex2D(_NoiseTex, i.uv).r;
				float whiteNoise = tex2D(_WhiteNoiseTex, i.uv).r;

				float normalizedDist = GetNormalizedDist(i.worldPos.y);
				float cutout = commonNoise * (1 - _DistanceEffect) + normalizedDist * _DistanceEffect;

				float edgeCutout = cutout - _Threshold;
				clip(edgeCutout + _AshWidth); //延至灰烬宽度处才剔除掉
				
				float degree = saturate(edgeCutout / _EdgeWidth);
				fixed4 edgeColor = tex2D(_RampTex, float2(degree, degree));
				fixed4 finalColor = fixed4(lerp(edgeColor, albedo, degree).rgb, 1);
				if(degree < 0.001)
				{
					clip(whiteNoise * _AshDensity + normalizedDist * _DistanceEffect - _Threshold); //灰烬处用白噪声来进行碎片化
					finalColor = _AshColor;
				}

				return finalColor;
			}
			ENDCG
		}
	}
}