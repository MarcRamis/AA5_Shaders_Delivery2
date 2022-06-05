Shader "Custom/VertexMovement" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpSize("Bump size", float) = 1
		_BumpStretch("Bump stretch", float) = 1
		_MainColor("Main color", Color) = (0,0,0,1)
		_BumpColor("Bump color", Color) = (0,0,0,1)
		_Diff1("Time Diff 1", float) = 3
		_Diff2("Time Diff 2", float) = 6
	}

		SubShader{
			Tags { "RenderType" = "Opaque" }

			CGPROGRAM
			#pragma surface surf Standard fullforwardshadows vertex:vert

			sampler2D _MainTex;

			float _BumpSize;
			float _BumpStretch;
			float4 _MainColor;
			float4 _BumpColor;
			float _Diff1;
			float _Diff2;

			struct Input {
				float2 uv_MainTex;
				float multiplyValue; //The Surface function will need this
			};

			fixed4 _Color;


			void vert(inout appdata_full v, out Input o) {

				float multiplyValue = abs(sin(_Time * 30 + v.vertex.y)); //how much we want to multiply our vertex
				//v.vertex.x *= multiplyValue * v.normal.x;
				//v.vertex.z *= multiplyValue * v.normal.y;

				float4 modifiedPos = v.vertex;
				float diff = fmod(_Time, _Diff1) - _Diff2;
				float dir = modifiedPos.y - diff;
				float stretch = clamp(dir * _BumpStretch, -3.14f, 3.14f);
				float result = clamp(cos(stretch), 0, 1);

				float3 bump = (v.normal * _BumpSize) * result;

				v.vertex += float4(bump, 1);

				UNITY_INITIALIZE_OUTPUT(Input, o);
				o.multiplyValue = multiplyValue; //assing the multiply data to the "Input" value, so the surface shader can use it

			}

			void surf(Input IN, inout SurfaceOutputStandard o) {

				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = lerp(c.rgb,
					float3(.3,.3,1),
					IN.multiplyValue);//the lerp factor is how much we've scaled our vertex
				o.Alpha = c.a;
			}
			ENDCG
	}

		FallBack "Diffuse"
}