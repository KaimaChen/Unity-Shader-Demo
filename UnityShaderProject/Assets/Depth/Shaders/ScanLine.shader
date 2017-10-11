//思路：当前深度值与_CurValue相近的返回扫描线颜色
Shader "Kaima/Depth/ScanLine"
{
	Properties
	{
		_MainTex("Origin Texture", 2D) = "white" {}
		_LineColor("Line Color", Color) = (0, 0.8, 0.2, 1)
		_LineWidth("Line Width", Range(0, 0.08)) = 0.05
		_CurValue("Current Value", Range(0, 0.9)) = 0 //控制扫描线的推进
	}
	SubShader
	{
		ZTest Always Cull Off ZWrite Off

		Tags { "RenderType"="Opaque" }

		Pass
		{
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
				float4 uv : TEXCOORD0; //xy for _MainTex, zw for _CameraDepthTexture
				float4 vertex : SV_POSITION;
			};

			sampler2D _CameraDepthTexture;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			fixed4 _LineColor;
			float _LineWidth;
			float _CurValue;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = float4(v.uv, v.uv);
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0)
						o.uv.w = 1 - o.uv.w;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 originColor = tex2D(_MainTex, i.uv.xy);
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.zw));
				float linear01Depth = Linear01Depth(depth);
				float halfWidth = _LineWidth / 2;
				float v = saturate(abs(_CurValue - linear01Depth) / halfWidth); //线内返回(0, 1)，线外返回1
				return lerp(_LineColor, originColor, v);

			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
