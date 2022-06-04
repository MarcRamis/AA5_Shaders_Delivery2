Shader "Hidden/Custom/Bloom"
{
	HLSLINCLUDE

		// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

#define PI 3.14159265359
#define E 2.71828182846

		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	float _intensity;
	float _quantity;
	sampler2D _temporalTex;
	sampler2D _finalBloom;

	float _Threshold = 1;

	float4 Prefilter(float3 c, float2 uv)
	{
		float brightness = max(c.r, max(c.g, c.b));
		float contribution = max(0, brightness - _Threshold);
		contribution /= max(brightness, 0.00001);
		if (length(c) > 15.0f)
			return float4(c * contribution, 0);
		else
			return float4(0, 0, 0, 0);
	}

	//float4 Check(float4 tex, float2 uv)
	//{
	//	float3 tempTex = tex2D(_temporalTex, uv);
	//	float color = max(tempTex.r, max(tempTex.g, tempTex.b));
	//	if (color > 0.1f)
	//	{
	//		return tex;
	//	}
	//	else
	//	{
	//		return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	//	}
	//}

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
		float2 uv = i.texcoord + float2(((index / (_quantity - 1) - 0.5) * _intensity * invAspect), 0);
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
		float2 uv = i.texcoord + float2(0, ((index2 / (_quantity - 1) - 0.5) * (_intensity * 2) * invAspect));
		// Add color at position to color
		col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
	}

	// Divide the sum of values by the amount of samples
	col = col / (_quantity );
	return col;
	
	}

		

		float4 FragBloom(VaryingsDefault i) : SV_Target
	{
		float4 col = float4(0,0,0,0);
		float2 uv = i.texcoord;
		
		for (int i = 0; i < 1; i++)
		{
			//col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
			col += tex2D(_temporalTex, uv);
		}
		//return Prefilter(col, uv);
		return col;
		//col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * float4(1, 1, 1, 1) * 0.5f;



	}

		float4 PreFrag(VaryingsDefault i) : SV_Target
	{
		float3 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float brightness = max(c.r, max(c.g, c.b));
		
		if (length(c) > 15.0f)
		{			
			return float4(c, 0);
		}
		else
		{
			return float4(0,0,0,0);
		}




	}

		float4 FinalFrag(VaryingsDefault i) : SV_Target
	{
		float4 originalTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float4 bloomTex = tex2D(_finalBloom, i.texcoord);
		
			return   bloomTex + originalTex;
		
		
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
			Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FragBloom
			ENDHLSL
		}
			Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment PreFrag
			ENDHLSL
		}
			Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment FinalFrag
			ENDHLSL
		}
			//Pass
			//{
			//	Blend One One
			//
			//	CGPROGRAM
			//		#pragma vertex VertDefault
			//		#pragma fragment FragmentProgram
			//	ENDCG
			//}
			//Pass
			//{
			//	CGPROGRAM
			//	#pragma vertex VertDefault
			//	#pragma fragment FragmentProgram2
			//	ENDCG
			//}
	}
}

