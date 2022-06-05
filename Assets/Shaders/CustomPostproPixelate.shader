Shader "Hidden/Custom/Pixelate"
{
	HLSLINCLUDE
	// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	
	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	
	float _pixelSize;
	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float2 N = float2(_ScreenParams.x / _pixelSize, _ScreenParams.y / _pixelSize);
		float2 uv = floor(i.texcoord * N) / N;
		
		float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
		return color;
	}
	ENDHLSL
	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
			Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Frag
			ENDHLSL
		}
	}
}
