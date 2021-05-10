#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

struct Attributes
{
    uint vertexID : SV_VertexID;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 texcoord   : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings Vertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
    output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
    return output;
}

TEXTURE2D(_InputTexture);
TEXTURE2D(_NoiseTexture);
float _Opacity;

float GetRandom(float2 p, float offs)
{
    return GenerateHashedRandomFloat((p + offs + 2) * _ScreenParams.xy) * 2 - 1;
}

float GetNoise(float2 p, float offs)
{
    return SAMPLE_TEXTURE2D(_NoiseTexture, s_linear_repeat_sampler, p + offs).r;
}

float3 SampleColor(float2 p)
{
    p.x *= _ScreenParams.y / _ScreenParams.x;
    p += 0.5;
    return SAMPLE_TEXTURE2D(_InputTexture, s_linear_clamp_sampler, p).rgb;
}

float SampleLuminance(float2 p)
{
    return Luminance(SampleColor(p));
}

float2 GetGradient(float2 p)
{
    float l = SampleLuminance(p);
    const float2 dx = float2(1.0 / 400, 0);
    float ldx = SampleLuminance(p + dx.xy) - SampleLuminance(p - dx.xy);
    float ldy = SampleLuminance(p + dx.yx) - SampleLuminance(p - dx.yx);
    ldx += GetRandom(p, 0) * 0.01;
    ldy += GetRandom(p, 1) * 0.01;
    return float2(ldx, ldy);
}

float2 Rotate90(float2 v)
{
    return v.yx * float2(-1, 1);
}

float4 Fragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 p = input.texcoord - 0.5;
    p.x *= _ScreenParams.x / _ScreenParams.y;

    float2 p_e_n = p;
    float2 p_e_p = p;
    float2 p_c_n = p;
    float2 p_c_p = p;

    const uint Iteration = 20;
    const float Stride = 1.0 / 800;

    float  acc_e = 0;
    float3 acc_c = 0;

    float sum_c = 0;

    for (uint i = 0; i < Iteration; i++)
    {
        {
            float2 grad = GetGradient(p_e_n);
            float edge = saturate(length(grad) * 10);
            float bw = smoothstep(0.4, 0.6, GetNoise(p_e_n * 0.2, 0));
            acc_e += lerp(1, bw, edge);
            p_e_n -= normalize(Rotate90(grad)) * Stride * 2;
        }

        {
            float2 grad = GetGradient(p_e_p);
            float edge = saturate(length(grad) * 10);
            float bw = smoothstep(0.4, 0.6, GetNoise(p_e_p * 0.2, 0));
            acc_e += lerp(1, bw, edge);
            p_e_p += normalize(Rotate90(grad)) * Stride * 2;
        }

        float w_c = 0.5 + (float)i / Iteration;

        {
            float2 grad = GetGradient(p_c_n);
            acc_c += SampleColor(p_c_n) * w_c;
            sum_c += w_c;
            p_c_n -= normalize(grad) * Stride;
        }

        w_c *= 0.3;

        {
            float2 grad = GetGradient(p_c_p);
            acc_c += SampleColor(p_c_p) * w_c;
            sum_c += w_c;
            p_c_p += normalize(grad) * Stride;
        }
    }

    acc_c /= sum_c;
    acc_e /= Iteration * 2;

    return float4(acc_c * acc_e, 1);
}
