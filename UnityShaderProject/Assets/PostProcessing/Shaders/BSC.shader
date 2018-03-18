Shader "Kaima/PostProcessing/BSC"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Assets/_Libs/Tools.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _Brightness;
			float _Saturation;
			float _Contrast;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed3 result = col.rgb * _Brightness;

				fixed lum = Luminance(col.rgb);
				result = lerp(fixed3(lum, lum, lum), result, _Saturation); 

				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				result = lerp(avgColor, result, _Contrast);

				return fixed4(result, 1);
			}
			ENDCG
		}
	}
}
