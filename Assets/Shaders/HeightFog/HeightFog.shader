Shader "Custom/HeightFog"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _FogTop ("FogTop", float) = 1
        _FogBottom ("FogBottom", float) = 1
        _FogColor ("FogColor", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float fog;
        };

        half _Glossiness;
        half _Metallic;

        float _FogTop;
        float _FogBottom;

        fixed4 _Color;
        fixed4 _FogColor;

        void vert (inout appdata_full v, out Input data)
        {
            UNITY_INITIALIZE_OUTPUT(Input, data);

            float4 pos = mul(unity_ObjectToWorld, v.vertex);

            data.fog = saturate( (_FogTop - pos.y) / (_FogTop - _FogBottom) ); // saturate от 0 до 1
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = lerp(c, _FogColor, IN.fog);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
