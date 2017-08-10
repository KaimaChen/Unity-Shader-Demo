Shader "Kaima/Outline/MoveInView"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_Outline("Outline", Range(0.0, 0.1)) = 0.05
	}
	SubShader
	{
		Pass //Outline
		{
			Cull Front
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed4 _OutlineColor;
			float _Outline;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); //convert normal from model coord to view  coord
				float2 offset = TransformViewToProjection(normal.xy); //ignore z to make the Outline dont change its size when the camera zoom in/out
				o.vertex.xy += offset * o.vertex.z * _Outline;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			fixed4 _MainColor;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _MainColor;
			}
			ENDCG
		}
	}
}
