Shader "Kaima/Other/PaperFold"
{
	Properties
	{
		_FrontText ("Front Tex", 2D) = "white" {}
		_BackTex  ("Back Tex", 2D) = "white" {}
		_FoldPos ("Fold Pos", float) = 5
		_FoldAngle   ("Fold Angle", Range(1, 180)) = 90
		[Toggle(ENABLE_DOUBLE)] _DoubleFold ("Double Fold", Float) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }

		Pass
		{
			ZWrite On
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature ENABLE_DOUBLE
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _FrontText;
			float4 _FrontText_ST;
			float _FoldPos, _FoldAngle;

			v2f vert (appdata_base v)
			{
				float angle = _FoldAngle;
				float r = _FoldPos - v.vertex.x;

				#if ENABLE_DOUBLE
					if(r <= 0)
						angle = 360 - _FoldAngle;
				#else
					if(r <= 0)
						angle = 180;
				#endif

				v.vertex.x = _FoldPos + r * cos(angle * UNITY_PI / 180);
				v.vertex.y = r * sin(angle * UNITY_PI / 180);
				
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _FrontText);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_FrontText, i.uv);
				return col;
			}
			ENDCG
		}

		Pass
		{
			ZWrite On
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature ENABLE_DOUBLE

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _BackTex;
			float4 _BackTex_ST;
			float _FoldPos, _FoldAngle;

			
			v2f vert (appdata_base v)
			{
				float angle = _FoldAngle;
				float r = _FoldPos - v.vertex.x;

				#if ENABLE_DOUBLE
					if(r <= 0)
						angle = 360 - _FoldAngle;
				#else
					if(r <= 0)
						angle = 180;
				#endif

				v.vertex.x = _FoldPos + r * cos(angle * UNITY_PI / 180);
				v.vertex.y = r * sin(angle * UNITY_PI / 180);
				 
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _BackTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_BackTex, i.uv);				
				return col;
			}
			ENDCG
		}
	}
}
