//摄像机穿过物体时产生Stipple来过渡

Shader "Kaima/Other/MoveStipple"
{
	Properties
	{
		_FadeNear("Fade Near", float) = 10
		_FadeFar("Fade Far", float) = 20
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

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD0;
				float4 cameraPos : TEXCOORD1;
			};

			float _FadeNear;
			float _FadeFar;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.cameraPos = mul(UNITY_MATRIX_MV, v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				const float4x4 thresholdMatrix = 
				{
					1, 9, 3, 11,
					13, 5, 15, 7,
					4, 12, 2, 10,
					16, 8, 14, 6
				};

				float2 screenPos = i.screenPos.xy / i.screenPos.w;
				screenPos.xy *= _ScreenParams.xy;

				float threshold = thresholdMatrix[screenPos.x % 4][screenPos.y % 4] / 17;
				float alpha = saturate((length(i.cameraPos.xyz) - _FadeNear) / (_FadeFar - _FadeNear));
				clip(alpha - threshold);
				
				return float4(1, 1, 1, 1);
			}
			ENDCG
		}
	}
}
