Shader "Kaima/Dissolve/Trifox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "gray" {}		
		_ScreenSpaceMask("Screen Space Mask", 2D) = "white" {}
		_WorkDistance("Work Distance", Float) = 20
		_PlayerPos("Player Pos", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float4 screenPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _ScreenSpaceMask;
			float _WorkDistance;
			float4 _PlayerPos;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float toCamera = distance(i.worldPos, _WorldSpaceCameraPos.xyz);
				float playerToCamera = distance(_PlayerPos.xyz, _WorldSpaceCameraPos.xyz);

				float2 wcoord = (i.screenPos.xy / i.screenPos.w);
				float mask = tex2D(_ScreenSpaceMask, wcoord).r;
				fixed4 col = tex2D(_MainTex, i.uv);
				float gradient = tex2D(_NoiseTex, i.uv).r;

				if(toCamera < playerToCamera)
					clip(gradient - mask + (toCamera - _WorkDistance) / _WorkDistance);

				return col;
			}
			ENDCG
		}
	}
}
