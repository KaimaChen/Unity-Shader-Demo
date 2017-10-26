Shader "Kaima/PostProcessing/LensCircle"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_InnerRadius("Inner Radius", Range(0, 1)) = 0.4
		_OuterRadius("Outer Radius", Range(0, 1)) = 0.5
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
			float _InnerRadius;
			float _OuterRadius;
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float2 center = float2(0.5, 0.5);
				float dist = distance(center, i.uv);
				col *= smoothstep(_OuterRadius, _InnerRadius, dist);
				return col;
			}
			ENDCG
		}
	}
}
