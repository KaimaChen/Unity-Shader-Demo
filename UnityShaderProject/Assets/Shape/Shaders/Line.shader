Shader "Kaima/Shape/Line"
{
	Properties
	{
		_StartEnd("Start(XY) End(ZW)", Vector) = (0, 0.5, 0, 0)
		_Width("Width", Range(0, 1)) = 0.01
		_Antialias("Antialias Width", Range(0, 0.1)) = 0.001
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

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

			float4 _StartEnd;
			float _Width;
			float _Antialias;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
 
			fixed4 frag (v2f i) : SV_Target
			{
				return Line(_StartEnd.xy, _StartEnd.zw, _Width, _Antialias, i.uv);               
			}
			ENDCG
		}
	}
}
