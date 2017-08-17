Shader "Kaima/Outline/MoveAlongVertexNormal"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_Outline("Outline", Range(0.0, 0.1)) = 0.05
		_Factor("Factor", Range(0, 2)) = 1
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
			float _Factor;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				float3 dir1 = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				float D = dot(dir1, dir2); //根据点积正负可以判断vertex是指向还是背离几何中心
				D *= _Factor;
				float3 dir = lerp(dir2, dir1, D);
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
