#pragma once

struct KinoAquaFilter
{
    // Data members

    KINO_AQUA_INPUT_TEXTURE(inputTexture);
    KINO_AQUA_NOISE_TEXTURE(noiseTexture);

    float4 edgeColor;
    float4 fillColor;

    float aspectRatio;
    float aspectRatioRcp;

    uint iteration;
    float iterationRcp;

    float interval;
    float blurWidth;
    float blurFrequency;
    float edgeContrast;
    float hueShift;

    // Basic math function

    float2 Rotate90(float2 v)
    {
        return v.yx * float2(-1, 1);
    }

    // Coordinate system conversion

    // UV to vertically normalized screen coordinates
    float2 UV2SC(float2 uv)
    {
        float2 p = uv - 0.5;
        p.x *= aspectRatio;
        return p;
    }

    // Vertically normalized screen coordinates to UV
    float2 SC2UV(float2 p)
    {
        p.x *= aspectRatioRcp;
        return p + 0.5;
    }

    // Texture sampling functions

    float3 SampleColor(float2 p)
    {
        return KINO_AQUA_SAMPLE_INPUT_TEXTURE(SC2UV(p)).rgb;
    }

    float SampleLuminance(float2 p)
    {
        return Luminance(SampleColor(p));
    }

    float3 SampleNoise(float2 p)
    {
        return KINO_AQUA_SAMPLE_NOISE_TEXTURE(p).rgb;
    }

    // Gradient function

    float2 GetGradient(float2 p, float freq)
    {
        const float2 dx = float2(interval / 200, 0);
        float ldx = SampleLuminance(p + dx.xy) - SampleLuminance(p - dx.xy);
        float ldy = SampleLuminance(p + dx.yx) - SampleLuminance(p - dx.yx);
        float2 n = SampleNoise(p * 0.4 * freq).gb - 0.5;
        return float2(ldx, ldy) + n * 0.05;
    }

    // Edge / fill processing functions

    float ProcessEdge(inout float2 p, float stride)
    {
        float2 grad = GetGradient(p, 1);
        float edge = saturate(length(grad) * 10);
        float pattern = SampleNoise(p * 0.8).r;
        p += normalize(Rotate90(grad)) * stride;
        return pattern * edge;
    }

    float3 ProcessFill(inout float2 p, float stride)
    {
        float2 grad = GetGradient(p, blurFrequency);
        p += normalize(grad) * stride;
        float shift = SampleNoise(p * 0.1).r * 2;
        return SampleColor(p) * HsvToRgb(float3(shift, hueShift, 1));
    }

    // Main filter function

    float3 ProcessAt(float2 uv)
    {
        // Gradient oriented blur effect

        float2 p = UV2SC(uv);

        float2 p_e_n = p;
        float2 p_e_p = p;
        float2 p_c_n = p;
        float2 p_c_p = p;

        const float Stride = 0.04 * iterationRcp;

        float  acc_e = 0;
        float3 acc_c = 0;
        float  sum_e = 0;
        float  sum_c = 0;

        for (uint i = 0; i < iteration; i++)
        {
            float w_e = 1.5 - i * iterationRcp;
            acc_e += ProcessEdge(p_e_n, -Stride) * w_e;
            acc_e += ProcessEdge(p_e_p, +Stride) * w_e;
            sum_e += w_e * 2;

            float w_c = 0.2 + i * iterationRcp;
            acc_c += ProcessFill(p_c_n, -Stride * blurWidth) * w_c;
            acc_c += ProcessFill(p_c_p, +Stride * blurWidth) * w_c * 0.3;
            sum_c += w_c * 1.3;
        }

        // Normalization and contrast

        acc_e /= sum_e;
        acc_c /= sum_c;

        acc_e = saturate((acc_e - 0.5) * edgeContrast + 0.5);

        // Color blending

        float3 rgb_e = lerp(1, edgeColor.rgb, edgeColor.a * acc_e);
        float3 rgb_f = lerp(1, acc_c, fillColor.a) * fillColor.rgb;

        return rgb_e * rgb_f;
    }
};

float3 KinoAquaOverlay(float3 c1, float3 c2, float alpha)
{
    float3 c;
#if defined(KINO_AQUA_MULTIPLY)
    c = c1 * c2;
#elif defined(KINO_AQUA_OVERLAY)
    float3 a = c1 * c2 * 2;
    float3 b = 1 - (1 - c1) * (1 - c2) * 2;
    c = lerp(a, b, c1 > 0.5);
#elif defined(KINO_AQUA_SCREEN)
    c = 1 - (1 - c1) * (1 - c2);
#else
    c = c1;
#endif
    return lerp(c1, c, alpha);
}
