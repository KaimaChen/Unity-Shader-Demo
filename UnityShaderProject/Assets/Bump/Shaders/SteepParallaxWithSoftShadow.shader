Shader "Kaima/Bump/SteepParallaxWithSoftShadow"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _NormalMap("Normal Map", 2D) = "bump" {}
		[NoScaleOffset] _DepthMap("Depth Map (R)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(32, 256)) = 64
		_HeightScale("Height Scale", Range(0,1)) = 0.2
		_MaxLayerNum("Max Layer Num", Range(1, 200)) = 30
		_MinLayerNum("Min Layer Num", Range(1, 100)) = 15
		_ShadowIntensity("Self Shadow Intensity", Range(0, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir_tangent : TEXCOORD1;
				float3 viewDir_tangent : TEXCOORD2;
			};

			struct parallaxDS
			{
				float2 uv;
				float height;
			};

			sampler2D _MainTex;
			sampler2D _NormalMap;
			sampler2D _DepthMap;
			fixed4 _SpecularColor;
			float _Gloss;
			float _HeightScale;
			float _MaxLayerNum;
			float _MinLayerNum;
			float _ShadowIntensity;

			parallaxDS ParallaxMapping(float2 uv, float3 viewDir_tangent)
			{
				float3 viewDir = normalize(-viewDir_tangent);

				float layerNum = lerp(_MaxLayerNum, _MinLayerNum, abs(dot(float3(0,0,1), viewDir)));
				float layerDepth = 1.0 / layerNum;
				float currentLayerDepth = 0.0;
				float2 deltaTexCoords = viewDir.xy / viewDir.z / layerNum * _HeightScale;

				float2 currentTexCoords = uv;
				float currentDepthMapValue = tex2D(_DepthMap, currentTexCoords).w;

				while(currentLayerDepth < currentDepthMapValue)
				{
					currentTexCoords -= deltaTexCoords;
					currentDepthMapValue = tex2Dlod(_DepthMap, float4(currentTexCoords, 0, 0)).r;
					currentLayerDepth += layerDepth;
				}

				parallaxDS o;
				o.height = currentLayerDepth;
				o.uv = currentTexCoords;
				return o;
			}

			float ParallaxShadow(float3 lightDir_tangent, float2 initialUV, float initialHeight)
			{
				float3 lightDir = normalize(lightDir_tangent);

				float shadowMultiplier = 1;

				const float minLayers = 15;
				const float maxLayers = 30;

				//只算正对阳光的面
				if(dot(float3(0, 0, 1), lightDir) > 0)
				{
					float numSamplesUnderSurface = 0;
					shadowMultiplier = 0;
					float numLayers = lerp(maxLayers, minLayers, abs(dot(float3(0, 0, 1), lightDir)));
					float layerHeight = initialHeight / numLayers;
					float2 texStep = _HeightScale * lightDir.xy / lightDir.z / numLayers;

					float currentLayerHeight = initialHeight - layerHeight;
					float2 currentTexCoords = initialUV + texStep;
					float heightFromTexture = tex2D(_DepthMap, currentTexCoords).r;
					int stepIndex = 1;

					while(currentLayerHeight > 0)
					{
						if(heightFromTexture < currentLayerHeight)
						{
							numSamplesUnderSurface += 1;
							float newShadowMultiplier = (currentLayerHeight - heightFromTexture) * (1.0 - stepIndex / numLayers);
							shadowMultiplier = max(shadowMultiplier, newShadowMultiplier);
						}

						stepIndex += 1;
						currentLayerHeight -= layerHeight;
						currentTexCoords += texStep;
						heightFromTexture = tex2Dlod(_DepthMap, float4(currentTexCoords, 0, 0)).r;
					}

					if(numSamplesUnderSurface < 1)
					{
						shadowMultiplier = 1;
					}
					else 
					{
						shadowMultiplier = 1.0 - shadowMultiplier;
					}
				}

				return shadowMultiplier;
			}
			
			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				
				TANGENT_SPACE_ROTATION;
				o.lightDir_tangent = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
				o.viewDir_tangent = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 lightDir = normalize(i.lightDir_tangent);
				float3 viewDir = normalize(i.viewDir_tangent);

				parallaxDS pds = ParallaxMapping(i.uv, viewDir);
				float2 uv = pds.uv;
				float parallaxHeight = pds.height;
				if(uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0) //去掉边上的一些古怪的失真
					discard;

				float shadowMultiplier = ParallaxShadow(lightDir, uv, parallaxHeight); 

				float3 normal = normalize(UnpackNormal(tex2D(_NormalMap, uv)));
				fixed4 albedo = tex2D(_MainTex, uv);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				float diff = saturate(dot(normal, i.lightDir_tangent));
				diff = diff * 0.8 + 0.2;
				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * diff;
				float3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(halfDir, normal)), _Gloss);

				fixed4 finalColor = fixed4(ambient + (diffuse + specular) * pow(shadowMultiplier, 4.0* _ShadowIntensity), 1.0);
				return finalColor;
			}
			ENDCG
		}
	}
}
