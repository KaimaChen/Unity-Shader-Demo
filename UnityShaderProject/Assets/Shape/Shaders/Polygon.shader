Shader "Kaima/Shape/Polygon"
{
	Properties
	{
		_Num("Num", Int) = 3
		_Size("Size", Range(0, 1)) = 0.5
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			int _Num;
			float _Size;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				i.uv = i.uv * 2 - 1; //[-1, 1]，(0,0)在正中心

				float a = atan2(i.uv.x, i.uv.y) + UNITY_PI; //[0, 2π]，将整个界面变成角度分布（极坐标系）
				float r = (2 * UNITY_PI) / float(_Num); //一条边对应的角度（中心连接边的两个端点）

				//a / r 相当于将整个界面按照r为单位进行分割，一共N份
				//floor(0.5 + *) 进行四舍五入
				//length(i.uv) 一个渐变的圆
				float d = cos(floor(0.5 + a / r) * r - a) * length(i.uv);
				
				float3 col = 1 - step(_Size, d);
				return fixed4(col, 1);
			}
			ENDCG
		}
	}
}
