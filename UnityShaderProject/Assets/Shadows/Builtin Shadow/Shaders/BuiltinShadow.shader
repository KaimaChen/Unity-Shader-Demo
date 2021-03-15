Shader "Kaima/Shadows/BuiltinShadow"
{
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			//注意：前向渲染这些设置仍然需要，否则即使使用了阴影相关的宏也没用
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase	

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				SHADOW_COORDS(1) //1. 定义阴影坐标变量
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TRANSFER_SHADOW(o); //2. 将阴影坐标转换为屏幕空间
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed shadow = SHADOW_ATTENUATION(i); //3. 对阴影图进行采样
				return shadow * fixed4(1.0, 1.0, 0.0, 1.0);
			}
			ENDCG
		}

		//投射阴影
		//通常是自己改了顶点位置或用了clip才需要定义这个东西，否则能到Fallback链里面找到就行
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}
