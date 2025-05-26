Shader "Unlit/HologramInstancingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)

        _TransparencyTex ("Transparency Texture", 2D) = "white" {}
        _Transparency ("Transparency", Range(0.0, 2.0)) = 0.25
        _TransparencySpeed ("Transparency Speed", float) = 0.25

        _CutoutTex ("Cutout Texture", 2D) = "white" {}
        _CutoutStrength ("Cutout Strength", Range(0.0, 1.0)) = 0.25

        _Speed ("Speed", Float) = 1
        _Frequency ("Frequency", Float) = 1
        _Distance ("Distance", Float) = 1
        _Amount ("Amount", Range(0.0, 1.0)) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}
        
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f // vertex to face
            {
                float2 uv : TEXCOORD0;
                float2 uv_Alpha : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _TransparencyTex;
            float4 _TransparencyTex_ST;
            sampler2D _CutoutTex;


            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TintColor)
                UNITY_DEFINE_INSTANCED_PROP(float, _Transparency)
                UNITY_DEFINE_INSTANCED_PROP(float, _TransparencySpeed)
                UNITY_DEFINE_INSTANCED_PROP(float, _CutoutStrength)
                UNITY_DEFINE_INSTANCED_PROP(float, _Distance)
                UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
                UNITY_DEFINE_INSTANCED_PROP(float, _Frequency)
                UNITY_DEFINE_INSTANCED_PROP(float, _Amount)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert(appdata v)
            {
                v2f o;
    
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
              
                float distance = UNITY_ACCESS_INSTANCED_PROP(Props, _Distance);
                float speed = UNITY_ACCESS_INSTANCED_PROP(Props, _Speed);
                float frequency = UNITY_ACCESS_INSTANCED_PROP(Props, _Frequency);
                float amount = UNITY_ACCESS_INSTANCED_PROP(Props, _Amount);
              
                v.vertex.z += sin(_Time.y * speed + v.vertex.y * frequency) * (distance * 0.1) * amount;
                v.vertex.x += sin(_Time.y * speed + v.vertex.y * frequency) * (distance * 0.1) * amount;
              
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_Alpha = TRANSFORM_TEX(v.uv, _TransparencyTex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                fixed4 col = tex2D(_MainTex, i.uv) * UNITY_ACCESS_INSTANCED_PROP(Props, _TintColor);

                float tSpeed = UNITY_ACCESS_INSTANCED_PROP(Props, _TransparencySpeed);

                i.uv_Alpha += _Time.x * tSpeed;

                fixed4 alpha = tex2D(_TransparencyTex, i.uv_Alpha);
                float t = UNITY_ACCESS_INSTANCED_PROP(Props, _Transparency);
                col.a = alpha * t;

                fixed4 cCol = tex2D (_CutoutTex, i.uv);
                float cStrength = UNITY_ACCESS_INSTANCED_PROP(Props, _CutoutStrength);
                clip(cCol - cStrength);

                return col;
            }

            ENDCG
        }
    }
}
