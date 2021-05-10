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

float2 UV2SC(float2 uv)
{
    float2 p = uv - 0.5;
    p.x *= _ScreenParams.x / _ScreenParams.y;
    return p;
}

float2 SC2UV(float2 p)
{
    p.x *= _ScreenParams.y / _ScreenParams.x;
    return p + 0.5;
}

float2 RandomVector(float2 p)
{
    float2 res = _ScreenParams.xy;
    float x = GenerateHashedRandomFloat((p + 10) * res);
    float y = GenerateHashedRandomFloat((p + 20) * res);
    return float2(x, y) * 2 - 1;
}

float GetNoise(float2 p)
{
    return SAMPLE_TEXTURE2D(_NoiseTexture, s_linear_repeat_sampler, p).r;
}

float3 SampleColor(float2 p)
{
    float2 uv = SC2UV(p);
    return SAMPLE_TEXTURE2D(_InputTexture, s_linear_clamp_sampler, uv).rgb;
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
    return float2(ldx, ldy) + RandomVector(p) / 100;
}

float2 Rotate90(float2 v)
{
    return v.yx * float2(-1, 1);
}

float ProcessEdge(inout float2 p, float stride)
{
    float2 grad = GetGradient(p);
    float edge = saturate(length(grad) * 10);
    float bw = smoothstep(0.5, 0.7, GetNoise(p * 0.2));
    p += normalize(Rotate90(grad)) * stride;
    return lerp(1, bw, smoothstep(0.4, 1, edge));
}

float3 ProcessFill(inout float2 p, float stride)
{
    float2 grad = GetGradient(p);
    p += normalize(grad) * stride;
    return SampleColor(p);
}

float4 Fragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 p = UV2SC(input.texcoord);

    float2 p_e_n = p;
    float2 p_e_p = p;
    float2 p_c_n = p;
    float2 p_c_p = p;

    const uint Iteration = 20;
    const float Stride = 1.0 / 800;

    float  acc_e = 0;
    float3 acc_c = 0;
    float  sum_c = 0;

    for (uint i = 0; i < Iteration; i++)
    {
        float w_c = 0.5 + (float)i / Iteration;
        acc_e += ProcessEdge(p_e_n, Stride * -2);
        acc_e += ProcessEdge(p_e_p, Stride * +2);
        acc_c += ProcessFill(p_c_n, -Stride) * w_c;
        acc_c += ProcessFill(p_c_p, +Stride) * w_c * 0.3;
        sum_c += w_c * 1.3;
    }

    acc_e /= Iteration * 2;
    acc_c /= sum_c;

    return float4(acc_c * acc_e, 1);
}
