Shader "Kaima/PostProcessing/Bloom"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_LuminanceThreshold("Luminance Threshold", Range(0, 1)) = 0.5
		_BlurSize("Blur Size", Range(0, 5)) = 2
	}

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "Assets/_Libs/Tools.cginc"

		struct v2fExtract {
			float4 vertex : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		struct v2fBloom {
			float4 vertex : SV_POSITION;
			half4 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BloomTex;
		float _LuminanceThreshold;
		float _BlurSize;

		v2fExtract vertExtract(appdata_img v)
		{
			v2fExtract o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			return o;
		}

		fixed4 fragExtract(v2fExtract i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex, i.uv);
			fixed val = clamp(Luminance(col) - _LuminanceThreshold, 0.0, 1.0);
			return col * val;
		}

		v2fBloom vertBloom(appdata_img v)
		{
			v2fBloom o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv.xy = v.texcoord;
			o.uv.zw = CorrectUV(v.texcoord, _MainTex_TexelSize);
			return o;
		}

		fixed4 fragBloom(v2fBloom i) : SV_Target
		{
			return tex2D(_MainTex, i.uv.xy) + tex2D(_BloomTex, i.uv.zw);
		}

		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vertExtract
			#pragma fragment fragExtract
			ENDCG
		}

		UsePass "Kaima/PostProcessing/GaussianBlur/GAUSSIAN_HOR"

		UsePass "Kaima/PostProcessing/GaussianBlur/GAUSSIAN_VERT"

		Pass
		{
			CGPROGRAM
			#pragma vertex vertBloom
			#pragma fragment fragBloom
			ENDCG
		}
	}
}
