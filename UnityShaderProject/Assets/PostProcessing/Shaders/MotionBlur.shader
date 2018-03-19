Shader "Kaima/PostProcessing/MotionBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurAmount("Blur Amount", Float) = 0.5
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		struct v2f
		{
			float4 vertex : SV_Position;
			half2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		float _BlurAmount;

		v2f vert(appdata_img v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			return o;
		}

		fixed4 fragRGB(v2f i) : SV_Target
		{
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}

		fixed4 fragA(v2f i) : SV_Target
		{
			return tex2D(_MainTex, i.uv);
		}

		ENDCG

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragRGB
			ENDCG
		}

		Pass
		{
			Blend One Zero
			ColorMask A
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragA
			ENDCG
		}
	}
}
