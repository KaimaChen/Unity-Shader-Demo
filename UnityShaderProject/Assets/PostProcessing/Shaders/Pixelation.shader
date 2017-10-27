Shader "Kaima/PostProcessing/Pixelation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PixelSize("Pixel Size", Range(0.0001, 0.1)) = 0.0001
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			float _PixelSize;
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 Pixelation(float2 uv)
			{
				uv = floor(uv / _PixelSize) * _PixelSize; //floor在制造梯度时经常使用
				return tex2D(_MainTex, uv);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return Pixelation(i.uv);
			}
			ENDCG
		}
	}
}
