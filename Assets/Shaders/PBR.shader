Shader "Unlit/PBR"
{
	Properties
	{
		 _objectColor("Main color",Color) = (0,0,0,1)
		 _ambientInt("Ambient int", Range(0,1)) = 0.25
		 _ambientColor("Ambient Color", Color) = (0,0,0,1)

		 _diffuseInt("Diffuse int", Range(0,1)) = 1
		_scecularExp("Specular exponent",Float) = 2.0

		_pointLightPos("Point light Pos",Vector) = (0,0,0,1)
		_pointLightColor("Point light Color",Color) = (0,0,0,1)
		_pointLightIntensity("Point light Intensity",Float) = 1

		_directionalLightDir("Directional light Dir",Vector) = (0,1,0,1)
		_directionalLightColor("Directional light Color",Color) = (0,0,0,1)
		_directionalLightIntensity("Directional light Intensity",Float) = 1

		_spotLightPos("Spot light Pos",Vector) = (0,0,0,1)
		_spotLightColor("Spot light Color",Vector) = (0,0,0,1)
		_spotLightIntensity("Spot light Intensity",Float) = 1
		_spotLightDir("Spot light Dir",Vector) = (0,1,0,1)

		_fresnelIntensity("Fresnel intensity", Range(0,1)) = 0.5
		_roughness("Roughness", Range(0.001, 1)) = 0.5
		_geometryCofficient("Geometry coefficient", Range(0.001, 4)) = 1

	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON
			#pragma multi_compile __ SPOT_LIGHT_ON
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 _objectColor;

			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _scecularExp;

			float4 _pointLightPos;
			float4 _pointLightColor;
			float _pointLightIntensity;

			float4 _directionalLightDir;
			float4 _directionalLightColor;
			float _directionalLightIntensity;

			float4 _spotLightPos;
			float4 _spotLightColor;
			float _spotLightIntensity;
			float4 _spotLightDir;

			float _fresnelIntensity;
			float _roughness;
			float _geometryCofficient;

			fixed4 frag(v2f i) : SV_Target
			{
				//3 phong model light components
				//We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = ambientComp;

				float PI = 3.1415926;
				float3 viewVec;
				float3 halfVec;
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 fresnel = float4(0, 0, 0, 1);
				float3 distribution = float4(0, 0, 0, 1);
				float3 geometry = float4(0, 0, 0, 1);
				float3 brdfComp = float4(0, 0, 0, 1);;
				float3 lightColor;
				float3 lightDir;
				float _sqrt;
				float k;
#if DIRECTIONAL_LIGHT_ON

				//Directional light properties
				lightColor = _directionalLightColor.xyz;
				lightDir = normalize(_directionalLightDir);

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal),0,1);

				// View vector & half vector
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);
				halfVec = normalize(viewVec + lightDir);

				// Fresnel Schlick
				fresnel = _fresnelIntensity + (1 - _fresnelIntensity) * pow(1 - dot(halfVec, lightDir),5);

				//Distribution GGX
				distribution = (pow(_roughness, 2)) / (PI * (pow(pow(dot(normalize(i.worldNormal), halfVec), 2) * (pow(_roughness, 2) - 1) + 1, 2)));

				// Geometry Implicit
				geometry = (dot(normalize(i.worldNormal), lightDir)) * (dot(normalize(i.worldNormal), viewVec)) * _geometryCofficient;

				brdfComp = (fresnel * geometry * distribution) / (4 * ((dot(i.worldNormal, lightDir)) * (dot(i.worldNormal, viewVec))));

				//finalColor = ambientComp;

				finalColor += clamp(float4(_directionalLightIntensity * (difuseComp + brdfComp), 1), 0, 1);
				//return float4(fresnel, 1);
#endif
#if POINT_LIGHT_ON

				//Point light properties
				lightColor = _pointLightColor.xyz;
				lightDir = _pointLightPos - i.wPos;
				float lightDist = length(lightDir);
				lightDir = lightDir / lightDist;
				float attenuation = 1.0 / (1.0f + 0.09f * lightDist + 0.032f * (lightDist * lightDist));
				//lightDir *= 4 * 3.14;

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal), 0, 1) / lightDist;
				difuseComp *= attenuation;

				// View vector & half vector
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);
				halfVec = normalize(viewVec + lightDir);

				// Fresnel Schlick
				fresnel = _fresnelIntensity + (1 - _fresnelIntensity) * pow(1 - dot(halfVec, lightDir), 5);

				//Distribution GGX
				distribution = (pow(_roughness, 2)) / (PI * (pow(pow(dot(normalize(i.worldNormal), halfVec), 2) * (pow(_roughness, 2) - 1) + 1, 2)));

				// Geometry Implicit
				geometry = (dot(normalize(i.worldNormal),lightDir)) * (dot(normalize(i.worldNormal), viewVec)) * _geometryCofficient;

				// BRDF Function
				brdfComp = (fresnel * geometry * distribution) / 4 * ((dot(i.worldNormal, lightDir)) * (dot(i.worldNormal, viewVec))) / lightDist;

				brdfComp *= attenuation;
				//finalColor = ambientComp * attenuation;

				finalColor += clamp(float4(_pointLightIntensity * (difuseComp + brdfComp),1), 0, 1);
				//return float4(distribution, 1);

#endif
#if SPOT_LIGHT_ON

				//Point light properties
				lightColor = _spotLightColor.xyz;
				lightDir = _spotLightPos - i.wPos;
				float lightDist2 = length(lightDir);
				lightDir = lightDir / lightDist2;
				attenuation = 5.0 / (1.0f + 0.09f * lightDist + 0.032f * (lightDist * lightDist));
				//lightDir *= 4 * 3.14;

				float theta = dot(lightDir, normalize(-_spotLightDir));

				if (theta < cos(14.5f))
				{
					// do lighting calculations
					//Diffuse componenet
					difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal), 0, 1) / lightDist2;
					difuseComp *= attenuation;
					// View vector & half vector
					viewVec = normalize(_WorldSpaceCameraPos - i.wPos);
					halfVec = normalize(viewVec + lightDir);

					// Fresnel Schlick
					fresnel = _fresnelIntensity + (1 - _fresnelIntensity) * pow(1 - dot(halfVec, lightDir), 5);

					//Distribution GGX
					distribution = (pow(_roughness, 2)) / (PI * (pow(pow(dot(normalize(i.worldNormal), halfVec), 2) * (pow(_roughness, 2) - 1) + 1, 2)));

					// Geometry Implicit
					geometry = (dot(normalize(i.worldNormal), lightDir)) * (dot(normalize(i.worldNormal), viewVec)) * _geometryCofficient;

					// BRDF Function
					brdfComp = (fresnel * geometry * distribution) / 4 * ((dot(i.worldNormal, lightDir)) * (dot(i.worldNormal, viewVec))) / lightDist2;
					brdfComp *= attenuation;
					//finalColor = ambientComp;

					finalColor += clamp(float4(_spotLightIntensity * (difuseComp + brdfComp), 1), 0, 1);
				}
				else
				{
					//return _objectColor;
				}
				
				
				

				

#endif

				return finalColor * _objectColor;
			}
			ENDCG
		}
		Pass
		{
			Tags {"LightMode" = "ShadowCaster"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
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
