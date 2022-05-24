Shader "Hidden/Kino/Aqua/HighDefinition"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma shader_feature _ KINO_AQUA_OVERLAY KINO_AQUA_MULTIPLY KINO_AQUA_SCREEN
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "KinoAqua.hlsl"
            ENDHLSL
        }
    }
    Fallback Off
}
