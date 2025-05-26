Shader "Unlit/SquareVignetteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0, 0, 1)
        _VignetteRadius("Vignette Radius", Range(0.0, 1.0)) = 0.0
        _VignetteSoft("Vignette Soft", Range(0.0, 1.0)) = 0.0
        _VignetteStrength("Vignette Strength", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            float _VignetteRadius;
            float _VignetteSoft;
            float _VignetteStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float distX = distance(float2(i.uv.x, i.uv.x), float2(0.5, 0.5));
                float distY = distance(float2(i.uv.y, i.uv.y), float2(0.5, 0.5));
                
                float vignetteX = 1 - smoothstep(_VignetteRadius - _VignetteSoft, _VignetteRadius, distX);
                float vignetteY = 1 - smoothstep(_VignetteRadius - _VignetteSoft, _VignetteRadius, distY);

                float vignette = 1 - vignetteX * vignetteY;

                return lerp(col, _Color, vignette * _VignetteStrength);
            }
            ENDCG
        }
    }
}
