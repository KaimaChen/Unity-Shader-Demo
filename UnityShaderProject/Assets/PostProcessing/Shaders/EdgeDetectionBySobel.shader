//利用Sobel来根据颜色值进行边缘检测
//https://www.wikiwand.com/en/Sobel_operator
//https://www.tutorialspoint.com/dip/sobel_operator.htm
Shader "Kaima/PostProcessing/EdgeDetectionBySobel"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Hardness("Hardness", Range(0, 5)) = 1
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
			#include "Assets/_Libs/Tools.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv[9] : TEXCOORD0;
			};

			sampler2D _MainTex;
			 float4 _MainTex_TexelSize;
			float _Hardness;
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = v.texcoord + _MainTex_TexelSize.xy * half2(-1, -1);
				o.uv[1] = v.texcoord + _MainTex_TexelSize.xy * half2(0, -1);
				o.uv[2] = v.texcoord + _MainTex_TexelSize.xy * half2(1, -1);
				o.uv[3] = v.texcoord + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[4] = v.texcoord + _MainTex_TexelSize.xy * half2(0, 0);
				o.uv[5] = v.texcoord + _MainTex_TexelSize.xy * half2(1, 0);
				o.uv[6] = v.texcoord + _MainTex_TexelSize.xy * half2(-1, 1);
				o.uv[7] = v.texcoord + _MainTex_TexelSize.xy * half2(0, 1);
				o.uv[8] = v.texcoord + _MainTex_TexelSize.xy * half2(1, 1);
				return o;
			}

			half Sobel(float2 uv[9])
			{
				const half verticalMask[9] = {-1, 0, 1,
						     -2, 0, 2,
						     -1, 0, 1};
				const half horizontalMask[9] = {-1, -2, -1,
						     0, 0, 0,
						     1, 2, 1};

				half edgeVertical = 0;
				half edgeHorizontal = 0;
				for(int i = 0; i < 9; i++)
				{
					half lum = Luminance(tex2D(_MainTex, uv[i]));
					edgeVertical += verticalMask[i] * lum * _Hardness;
					edgeHorizontal += horizontalMask[i] * lum * _Hardness;
				}

				return abs(edgeVertical) + abs(edgeHorizontal);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 originUV = i.uv[4];

				half edge = Sobel(i.uv);
				return edge;
			}
			ENDCG
		}
	}
}
