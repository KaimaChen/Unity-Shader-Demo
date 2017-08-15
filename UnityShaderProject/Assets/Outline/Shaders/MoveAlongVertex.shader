Shader "Kaima/Outline/MoveAlongVertex"
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
			Cull Front //因为开启了深度写入，因此要剔除正面以免遮住原物体
			ZWrite On //开启深度写入来保证两个物体重叠时还能显示出边缘

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

				//沿顶点方向进行偏移
				float3 dir = normalize(v.vertex.xyz);
				dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir); 
				float2 offset = TransformViewToProjection(dir.xy);
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
