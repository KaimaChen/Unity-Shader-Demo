Shader "Kaima/PostProcessing/GaussianBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BlurSize("Blur Size", Range(0, 5)) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		struct v2f {
			float4 vertex : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;

		v2f vertHorizontal(appdata_img v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

			half2 uv = v.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

			return o;
		}

		v2f vertVertical(appdata_img v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

			half2 uv = v.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.x * 1.0) * _BlurSize;
			o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.x * 1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.x * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.x * 2.0) * _BlurSize;

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float weight[3] = {0.4026, 0.2442, 0.0545}; //高斯核

			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

			sum += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[2]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[3]).rgb * weight[2];
			sum += tex2D(_MainTex, i.uv[4]).rgb * weight[2];

			return fixed4(sum, 1);
		}

		ENDCG

		Pass
		{
			NAME "GAUSSIAN_HOR"
			CGPROGRAM
			#pragma vertex vertHorizontal
			#pragma fragment frag
			ENDCG
		}

		Pass
		{
			NAME "GAUSSIAN_VERT"
			CGPROGRAM
			#pragma vertex vertVertical
			#pragma fragment frag
			ENDCG
		}
	}
}
