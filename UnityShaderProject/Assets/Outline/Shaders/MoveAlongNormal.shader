Shader "Kaima/Outline/MoveAlongNormal"
{
	Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_Outline("Outline", Range(0.0, 0.1)) = 0.05
	}
	SubShader
	{
		Pass //outline
		{
			Cull Off
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"

			struct v2f {
				float4 vertex : SV_POSITION;
			};

			fixed4 _OutlineColor;
			float _Outline;

			v2f vert(appdata_full v)
			{
				v2f o;
				v.vertex.xyz += v.normal * _Outline; //move the vertex along normal
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			float4 frag(v2f i) : COLOR
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
