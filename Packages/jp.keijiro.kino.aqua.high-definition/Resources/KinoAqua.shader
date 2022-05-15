Shader "Hidden/Kino/Aqua/HighDefinition"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "KinoAqua.hlsl"
            ENDHLSL
        }
    }
    Fallback Off
}
