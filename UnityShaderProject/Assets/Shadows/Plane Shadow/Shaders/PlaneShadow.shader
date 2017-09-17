Shader "Kaima/Shadows/PlaneShadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass //正常着色
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		Pass  //阴影
		{
			Offset -1, -1 //解决Z Fighting
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
			};

			float4x4 _Ground2World;
			float4x4 _World2Ground;

			//利用相似三角形计算阴影位置
			float4 CalculateShadowPos(float4 pos, float3 lightDir)
			{
				pos.x -= lightDir.x * pos.y / lightDir.y;
				pos.z -= lightDir.z * pos.y / lightDir.y;
				pos.y = 0; //在平面上
				return pos;
			}
			
			v2f vert (appdata v)
			{
				//将光线方向转到地面所在坐标系
				float3 lightDir = WorldSpaceLightDir(v.vertex);
				lightDir = normalize(mul((float3x3)_World2Ground, lightDir));
				//将顶点方向转到地面所在坐标系
				float4 pos = mul(unity_ObjectToWorld, v.vertex);
				pos = mul(_World2Ground, pos);
				//计算阴影位置
				pos = CalculateShadowPos(pos, lightDir);
				//将阴影切回本地空间
				pos = mul(_Ground2World, pos);
				pos = mul(unity_WorldToObject, pos);

				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0.5, 0.5, 0.5, 1);
			}

			ENDCG
		}
	}
}
