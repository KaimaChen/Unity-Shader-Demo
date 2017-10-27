//色调分离：http://www.geeks3d.com/20091027/shader-library-posterization-post-processing-effect-glsl/
Shader "Kaima/PostProcessing/Posterization"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Num("Num", Float) = 8.0
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
			float _Num;
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 Posterization(fixed3 col)
			{
				col = col * _Num;
				col = floor(col);
				col = col / _Num;
				return fixed4(col, 1);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return Posterization(col);
			}
			ENDCG
		}
	}
}
