Shader "Kaima/Dissolve/FromDirectionX"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_Threshold("Threshold", Range(0.0, 1.0)) = 0.5
		_EdgeLength("Edge Length", Range(0.0, 0.2)) = 0.1
		_RampTex("Ramp", 2D) = "white" {}
		_Direction("Direction", Int) = 1 //1表示从X正方向开始，其他值则从负方向
		_MinBorderX("Min Border X", Float) = -0.5 //从程序传入
		_MaxBorderX("Max Border X", Float) = 0.5  //从程序传入
		_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uvMainTex : TEXCOORD0;
				float2 uvNoiseTex : TEXCOORD1;
				float2 uvRampTex : TEXCOORD2;
				float objPosX : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Threshold;
			float _EdgeLength;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			int _Direction;
			float _MinBorderX;
			float _MaxBorderX;
			float _DistanceEffect;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.uvRampTex = TRANSFORM_TEX(v.uv, _RampTex);

				o.objPosX = v.vertex.x;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float range = _MaxBorderX - _MinBorderX;
				float border = _MinBorderX;
				if(_Direction == 1) //1表示从X正方向开始，其他值则从负方向
					border = _MaxBorderX;

				float dist = abs(i.objPosX - border);
				float normalizedDist = saturate(dist / range);

				fixed cutout = tex2D(_NoiseTex, i.uvNoiseTex).r * (1 - _DistanceEffect) + normalizedDist * _DistanceEffect;
				clip(cutout - _Threshold);

				float degree = saturate((cutout - _Threshold) / _EdgeLength);
				fixed4 edgeColor = tex2D(_RampTex, float2(degree, degree));

				fixed4 col = tex2D(_MainTex, i.uvMainTex);

				fixed4 finalColor = lerp(edgeColor, col, degree);
				return fixed4(finalColor.rgb, 1);
			}
			ENDCG
		}
	}
}
