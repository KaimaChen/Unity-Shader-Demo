Shader "Kaima/Normal/PrintNormal"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthNormalsTexture;

			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = CorrectUV(v.texcoord, _MainTex_TexelSize);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 normal = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv));
				return fixed4(normal * 0.5 + 0.5, 1);
			}
			ENDCG
		}
	}
}
