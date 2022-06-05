Shader "Unlit/VertexAnim"
{
    Properties
    {
        _BumpSize("Bump size", float) = 1
        _BumpStretch("Bump stretch", float) = 1
        _MainColor("Main color", Color) = (0,0,0,1)
        _BumpColor("Bump color", Color) = (0,0,0,1)
        _Diff1("Time Diff 1", float) = 3
        _Diff2("Time Diff 2", float) = 6
        _MainTex("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}
        //LOD 100

        
            CGPROGRAM
            //#pragma vertex vert
            #pragma surface surf Standard fullforwardshadows vertex:vert addshadow
            #pragma target 3.0
            //#pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
            

            #include "UnityCG.cginc"

            //struct appdata
            //{
            //    float4 vertex : POSITION;
            //    float2 uv : TEXCOORD0;
            //    float3 normal : NORMAL;
            //};
            //
            //struct v2f
            //{
            //    float2 uv : TEXCOORD0;
            //    float4 vertex : SV_POSITION;
            //    float3 worldNormal : TEXCOORD1;
            //};

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;

            float _BumpSize;
            float _BumpStretch;
            float4 _MainColor;
            float4 _BumpColor;
            float _Diff1;
            float _Diff2;

            float BumpResult(float2 uv)
            {
                float diff = fmod(_Time.y, _Diff1) - _Diff2;
                float dir = uv.y - diff;
                float stretch = clamp(dir * _BumpStretch, -3.14f, 3.14f);
                float result = clamp(cos(stretch), 0, 1);

                return result;
            }

            /*v2f*/void vert(inout appdata_full data)
            {
                float4 modifiedPos = data.vertex;
                float diff = fmod(_Time.y, _Diff1) - _Diff2;
                float dir = modifiedPos.y - diff;
                float stretch = clamp(dir * _BumpStretch, -3.14f, 3.14f);
                float result = clamp(cos(stretch), 0, 1);

                float3 bump = (data.normal * _BumpSize) * result;

                data.vertex += float4(bump, 0);
            }

            void surf(Input i, inout SurfaceOutputStandard o) 
            {
                //sample and tint albedo texture
                fixed4 col = tex2D(_MainTex, i.uv_MainTex);
                col *= _MainColor;
                o.Albedo = col.rgb;
                //just apply the values for metalness, smoothness and emission
                o.Metallic = 0.1f;
                o.Smoothness = 0.8f;
                o.Emission = 0.0f;
            }

            //fixed4 frag(v2f i) : SV_Target
            //{
            //    //return lerp(_MainColor, _BumpColor, BumpResult(i.uv));

            //    return tex2D(_MainTex, i.uv) + lerp(_MainColor, _BumpColor, BumpResult(i.uv));
            //}
        ENDCG
    
    }
        FallBack "Standard"
}