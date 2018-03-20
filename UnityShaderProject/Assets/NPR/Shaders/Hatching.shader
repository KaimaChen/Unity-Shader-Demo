Shader "Kaima/NPR/Hatching"
{
	Properties
	{
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(0, 1)) = 0.2
		_ZOffset("Z Offset", Float) = -0.5
		_Tile("Tile", Float) = 8
		_HatchTex0("Hatch Tex 0", 2D) = "white" {}
		_HatchTex1("Hatch Tex 1", 2D) = "white" {}
		_HatchTex2("Hatch Tex 2", 2D) = "white" {}
		_HatchTex3("Hatch Tex 3", 2D) = "white" {}
		_HatchTex4("Hatch Tex 4", 2D) = "white" {}
		_HatchTex5("Hatch Tex 5", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		UsePass "Kaima/NPR/Silhouette/ProceduralGeometrySilhouette-VertexNormal/OUTLINE"

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 weights0 : TEXCOORD1;
				float4 weights1 : TEXCOORD2;
			};

			float _Tile;
			sampler2D _HatchTex0;
			sampler2D _HatchTex1;
			sampler2D _HatchTex2;
			sampler2D _HatchTex3;
			sampler2D _HatchTex4;
			sampler2D _HatchTex5;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord * _Tile;

				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed diff = saturate(dot(worldNormal, worldLightDir));
				float hatchFactor = diff * 7.0;

				o.weights0 = float3(0, 0, 0);
				o.weights1 = float4(0, 0, 0, 1);
				if(hatchFactor > 6.0)
				{
					//最亮的部分，用留白表示
				}
				else if(hatchFactor > 5.0)
				{
					o.weights0.x = hatchFactor - 5.0;
				}
				else if(hatchFactor > 4.0)
				{
					o.weights0.x = hatchFactor - 4.0;
					o.weights0.y = 1.0 - o.weights0.x;
				}
				else if(hatchFactor > 3.0)
				{
					o.weights0.y = hatchFactor - 3.0;
					o.weights0.z = 1 - o.weights0.y;
				}
				else if(hatchFactor > 2.0)
				{
					o.weights0.z = hatchFactor - 2.0;
					o.weights1.x = 1 - o.weights0.z;
				}
				else if(hatchFactor > 1.0)
				{
					o.weights1.x = hatchFactor - 1.0;
					o.weights1.y = 1 - o.weights1.x;
				}
				else
				{
					o.weights1.y = hatchFactor;
					o.weights1.z = 1 - o.weights1.y;
				}
				o.weights1.w = 1 - o.weights0.x - o.weights0.y - o.weights0.z - o.weights1.x - o.weights1.y - o.weights1.z;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 hatch0 = tex2D(_HatchTex0, i.uv) * i.weights0.x;
				fixed4 hatch1 = tex2D(_HatchTex1, i.uv) * i.weights0.y;
				fixed4 hatch2 = tex2D(_HatchTex2, i.uv) * i.weights0.z;
				fixed4 hatch3 = tex2D(_HatchTex3, i.uv) * i.weights1.x;
				fixed4 hatch4 = tex2D(_HatchTex4, i.uv) * i.weights1.y;
				fixed4 hatch5 = tex2D(_HatchTex5, i.uv) * i.weights1.z;
				fixed4 white = fixed4(1,1,1,1) * i.weights1.w;

				fixed4 result = hatch0 + hatch1 + hatch2 + hatch3 + hatch4 + hatch5 + white;
				return result;
			}
			ENDCG
		}
	}
}
