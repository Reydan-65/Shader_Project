Shader "Unlit/ColorCorrectionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

        _Brightness("Brightness" , Range(-0.5, 0.5)) = 0
        _Contrast("Contrast" , Range(0, 2)) = 0
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
            float _Brightness;
            float _Contrast;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 Contrast (fixed4 color, float contrast)
            {
                float midPoint = pow(0.5, 2.2);

                return (color - midPoint) * contrast + midPoint;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) + _Color * 0.1;

                col += _Brightness;
                col = Contrast(col, _Contrast);

                return col;
            }
            ENDCG
        }
    }
}
