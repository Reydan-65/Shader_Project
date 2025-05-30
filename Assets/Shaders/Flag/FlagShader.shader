Shader "Unlit/FlagShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", float) = 0
        _Speed ("Speed", float) = 0
        _Frequency ("Frequency", float) = 0
        _AmplitudeY ("Amplitude Y", float) = 0
        _AmplitudeZ ("Amplitude Z", float) = 0
        _OffsetZ ("Offset Z", float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Cull off

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

            struct v2f // vertex to face
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _NoiseScale;
            float _Speed;
            float _Frequency;
            float _AmplitudeZ;
            float _AmplitudeY;
            float _OffsetZ;

            // Unity Noise
            float2 unity_gradientNoise_dir(float2 p)
            {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
     
            float unity_gradientNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(unity_gradientNoise_dir(ip), fp);
                float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }
     
            float Unity_GradientNoise_float(float2 UV, float Scale)
            {
                return unity_gradientNoise(UV * Scale) + 0.5;
            }

            v2f vert(appdata v)
            {
                v2f o;

                float x = v.uv.x * _Frequency + _CosTime.x * _Speed;
                float y = v.uv.y * _Frequency + _SinTime.x * _Speed;

                fixed4 noise = Unity_GradientNoise_float(float2(x, y), _NoiseScale);
               
                float factor = pow(v.uv.x, 0.5);

                float yOffset = noise.x * _AmplitudeY * factor;
                float zOffset = noise.x * _AmplitudeZ * factor * _OffsetZ;

                v.vertex.y += yOffset;
                v.vertex.z -= zOffset;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }

            ENDCG
        }
    }
}
