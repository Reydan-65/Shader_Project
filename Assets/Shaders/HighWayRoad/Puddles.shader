Shader "Custom/Puddles"
{
    Properties
    {
        [Header (Main)]
        _MainColor ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "white" {}
        _NormalStrength ("Normal Strength", Range(0,1)) = 0.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        [Header (Puddles)]
        _PuddleMask ("Puddle Mask", 2D) = "white" {}
        _PuddleNormalTex ("Puddle Normal", 2D) = "white" {}
        _PuddleNormalStrength ("Puddle Normal Strength", Range(0,1)) = 0.0
        _PuddleSpeed ("Puddle Speed", float) = 0.5
        _PuddleColor ("Puddle Color", Color) = (1,1,1,1)
        _PuddleStrength ("Puddle Strength", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _PuddleMask;
        sampler2D _NormalTex;
        sampler2D _PuddleNormalTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_PuddleMask;
            float2 uv_PuddleNormalTex;
        };

        fixed4 _MainColor;
        fixed4 _PuddleColor;

        half _Glossiness;
        half _Metallic;
        half _NormalStrength;

        half _PuddleNormalStrength;
        half _PuddleSpeed;
        half _PuddleStrength;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 mask = tex2D (_PuddleMask, IN.uv_PuddleMask) * _PuddleStrength;

            fixed4 mainColor = tex2D (_MainTex, IN.uv_MainTex) * _MainColor;
            fixed4 finalColor = lerp (mainColor, mainColor * _PuddleColor, mask);
            o.Albedo = finalColor;

            o.Smoothness = mask * _Glossiness;

            float2 puddleUV = IN.uv_PuddleNormalTex;
            puddleUV.x += _CosTime.x * 0.1 * _PuddleSpeed;
            puddleUV.y += _SinTime.x * 0.1 * _PuddleSpeed;

            float3 baseNormal = lerp(float3(0.5,0.5,0.5), tex2D (_NormalTex, IN.uv_MainTex), _NormalStrength);
            float3 puddleNormal = lerp(float3(0.5,0.5,0.5), tex2D (_PuddleNormalTex, puddleUV), _PuddleNormalStrength);
            o.Normal = lerp(baseNormal, puddleNormal, smoothstep(0, 0.3, mask)); // smoothstep, если < a то 0 если > b то = 1

            o.Metallic = _Metallic;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
