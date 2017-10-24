Shader "Kaima/PostProcessing/DreamVision"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 DreamVision(float2 uv)
			{
				fixed4 col = tex2D(_MainTex, uv);

				//模糊化
				col += tex2D(_MainTex, uv + 0.001);
				col += tex2D(_MainTex, uv + 0.003);
				col += tex2D(_MainTex, uv + 0.005);
				col += tex2D(_MainTex, uv + 0.007);
				col += tex2D(_MainTex, uv + 0.009);
				col += tex2D(_MainTex, uv + 0.011);

				col += tex2D(_MainTex, uv + 0.001);
				col += tex2D(_MainTex, uv + 0.003);
				col += tex2D(_MainTex, uv + 0.005);
				col += tex2D(_MainTex, uv + 0.007);
				col += tex2D(_MainTex, uv + 0.009);
				col += tex2D(_MainTex, uv + 0.011);

				col = col / 9.5;

				col.rgb = (col.r + col.g + col.b) / 3.0; //黑白化
				
				return col;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return DreamVision(i.uv);
			}
			ENDCG
		}
	}
}
