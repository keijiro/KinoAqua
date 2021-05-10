Shader "Hidden/Kino/PostProcess/Aqua"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "Aqua.hlsl"
            ENDHLSL
        }
    }
    Fallback Off
}
