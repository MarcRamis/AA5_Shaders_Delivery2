Shader "Hidden/Custom/Blur"
{
	HLSLINCLUDE
	
	// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
	#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
	
	#define PI 3.14159265359
	#define E 2.71828182846
	
	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	float _intensity;
	float _quantity;

	float _StandardDeviation = 0.02;

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		//calculate aspect ratio
		float invAspect = _ScreenParams.y / _ScreenParams.x;
		//init color variable
		float4 col = 0;
		
		// ITERATE over blur samples
		// Horizontal blur
		for (float index = 0; index < _quantity; index++)
		{
			// Get uv coordinate of sample
			float2 uv = i.texcoord + float2( ( (index / (_quantity - 1) - 0.5) * _intensity * invAspect), 0);
			// Add color at position to color
			col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
		}
		
		// Divide the sum of values by the amount of samples
		col = col / (_quantity);
		return col;

	}

	float4 Frag2(VaryingsDefault i) : SV_Target
	{
		//calculate aspect ratio
		float invAspect = _ScreenParams.y / _ScreenParams.x;
		//init color variable
		float4 col = 0;

		// ITERATE over blur samples

		// Vertical blur
		for (float index2 = 0; index2 < _quantity; index2++)
		{
			// Get uv coordinate of sample
			float2 uv = i.texcoord + float2(0, ((index2 / (_quantity - 1) - 0.5) * _intensity * invAspect));
			// Add color at position to color
			col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
		}

		// Divide the sum of values by the amount of samples
		col = col / (_quantity);
		return col;

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
		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Frag2
			ENDHLSL
		}
	}
}
