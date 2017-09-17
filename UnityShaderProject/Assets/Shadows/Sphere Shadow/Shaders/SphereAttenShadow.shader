Shader "Kaima/Shadows/SphereAttenShadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FadeControl("Fade Control", Float) = 1.0
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
				float3 worldPos : TEXCOORD1;
				float3 worldLightDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _SpherePos;
			float _SphereRadius;
			float _FadeControl;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldLightDir = WorldSpaceLightDir(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldLightDir = normalize(i.worldLightDir);
				float3 toSphere = normalize(_SpherePos - i.worldPos);
				float angle = acos(dot(worldLightDir, toSphere)); //到圆向量和到光源向量的夹角

				float distToSphere = length(_SpherePos - i.worldPos);
				float maxAngle = atan(_SphereRadius / distToSphere); //圆覆盖的角度

				if(angle < maxAngle) //处于圆覆盖的范围
				{
					float atten = (angle / maxAngle)  / _FadeControl;
					return smoothstep(0, 1, atten);
				}
				else 
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					return col;
				}

				
			}
			ENDCG
		}
	}
}
