Shader "Kaima/Shape/Box"
{
	Properties
	{
		_Position("Position (XY)", Vector) = (0.5,0.5,0,0)
		_Size("Size", Vector) = (0.3,0.3,0,0)
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
			#include "Assets/_Libs/Easing.cginc"

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

			float4 _Position;
			float4 _Size;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float box(float2 position, float2 size, float2 st)
			{
				float2 s = position - size * 0.5;
				float2 uv = smoothstep(s, s + 0.001, st);
				uv *= smoothstep(s, s + 0.001, 2 * position - st);
				return uv.x * uv.y;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return box(_Position, _Size.xy, i.uv);
			}
			ENDCG
		}
	}
}
