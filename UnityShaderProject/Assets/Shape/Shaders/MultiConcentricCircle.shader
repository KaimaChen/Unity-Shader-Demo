Shader "Kaima/Shape/MultiConcentricCircle"
{
	Properties
	{
		_Center("Center (XY)", Vector) = (0.5, 0.5, 0, 0) //只用到XY分量，且需要是[0, 1]
		_ConcentricNum("Concentric Num", Float) = 5
		_Num("Num", Float) = 4
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

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float4 _Center;
			float _ConcentricNum;
			float _Num;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 st = frac(i.uv * _ConcentricNum);
				float v = distance(st, _Center);
				v = frac(v * _Num);
				fixed3 col = v;
				
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
