// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

/*
Copyright (c) 2015 Kyle Halladay

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

Shader "KH/Dissolve/Dissolve Origin Point" 
{
	Properties 
	{
		_MainTex ("Diffuse (RGBA)", 2D) = "white"{}
		_BurnGradient("Burn Gradient (RGB)", 2D) = "white"{}
		_NoiseTex ("Burn Map (RGB)", 2D) = "black"{}
		_DissolveValue ("Value", Range(0,1)) = 1.0
		_HitPos("Position", Vector) = (0.0,0.0,0.0,0.0)
		_GradientAdjust ("Gradient", Range(0.1,10.0)) = 10.0
		_LargestVal ("Largest Value", float) = 1.0
	}
	SubShader 
	{
		Tags {"Queue" = "Transparent"}
		
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull back
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			sampler2D _BurnGradient;
			sampler2D _NoiseTex;
			float _DissolveValue;
			float4 _HitPos;
			float _LargestVal;
			float _GradientAdjust;
			struct vIN
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
			
			struct vOUT
			{
				float4 pos : SV_POSITION;
				float3 oPos : TEXCOORD2;
				float3 hitPos : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};
			
			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				o.oPos = v.vertex;
				o.hitPos = mul(unity_WorldToObject, _HitPos).xyz;
				return o;
			}
			
			float sqrMagnitude(float3 v)
			{
				return (v.x*v.x + v.y*v.y + v.z*v.z);
			}
			
			fixed4 frag(vOUT i) : COLOR
			{
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				fixed noiseVal = tex2D(_NoiseTex, i.uv).r;
				
				fixed toPoint =  (length(i.oPos.xyz - i.hitPos.xyz) / ((1.0001 - _DissolveValue) * _LargestVal));
				fixed d = ( (2.0 * _DissolveValue + noiseVal) * toPoint * noiseVal ) - 1.0;

				fixed overOne = saturate(d * _GradientAdjust);

				fixed4 burn = tex2D(_BurnGradient, float2(overOne, 0.5));
				return mainTex * burn;
			}

			ENDCG
		}
	} 
}
