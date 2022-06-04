Shader "Hidden/Custom/Vignette"
{
	HLSLINCLUDE
	// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	
	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	
	float _size;
	float2 _framePos;
	float _falloff;
	float4 _screenColor;

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float2 coord = pow((i.texcoord * 2.0) - _framePos,1);
		
		float vignetteSize = pow(sqrt(dot(coord, coord)) * _size, _falloff) + 1.0; 
		vignetteSize = 1.0 / pow(vignetteSize, 2);

		float vignetteSize2 = pow(sqrt(dot(coord, coord)) * _size, -_falloff) + 1.0;
		vignetteSize2 = 1.0 / pow(vignetteSize, 2);
		
		float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		return float4((color.rgb * vignetteSize), color.a) + float4(_screenColor.rgb * vignetteSize2, 0);
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
