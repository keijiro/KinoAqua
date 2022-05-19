#define KINO_AQUA_INPUT_TEXTURE(n) TEXTURE2D(n)
#define KINO_AQUA_NOISE_TEXTURE(n) TEXTURE2D(n)

#ifdef UNITY_COLORSPACE_GAMMA
#define KINO_AQUA_SAMPLE_INPUT_TEXTURE(p) \
  SRGBToLinear(SAMPLE_TEXTURE2D(inputTexture, s_linear_clamp_sampler, p))
#else
#define KINO_AQUA_SAMPLE_INPUT_TEXTURE(p) \
  SAMPLE_TEXTURE2D(inputTexture, s_linear_clamp_sampler, p)
#endif

#define KINO_AQUA_SAMPLE_NOISE_TEXTURE(p) \
  SAMPLE_TEXTURE2D(noiseTexture, default_sampler_Linear_Repeat, p)

SAMPLER(s_linear_clamp_sampler);

#include "Packages/jp.keijiro.kino.aqua/Shaders/KinoAquaFilter.hlsl"

TEXTURE2D(_NoiseTexture);

float2 _EffectParams2;
float4 _EdgeColor;
float4 _FillColor;
uint _Iteration;

void AquaEffect_float(float2 UV, out float3 Out)
{
    KinoAquaFilter aqua;

    aqua.inputTexture = _MainTex;
    aqua.noiseTexture = _NoiseTexture;

    aqua.edgeColor = _EdgeColor;
    aqua.fillColor = _FillColor;

    uint width, height;
    _MainTex.GetDimensions(width, height);

    aqua.aspectRatio = (float)width / height;
    aqua.aspectRatioRcp = 1 / aqua.aspectRatio;

    aqua.iteration = _Iteration;
    aqua.iterationRcp = 1.0 / _Iteration;

    aqua.interval      = _EffectParams1.y;
    aqua.blurWidth     = _EffectParams1.z;
    aqua.blurFrequency = _EffectParams1.w;
    aqua.edgeContrast  = _EffectParams2.x;
    aqua.hueShift      = _EffectParams2.y;

    Out = aqua.ProcessAt(UV);

#ifdef UNITY_COLORSPACE_GAMMA
    Out = LinearToSRGB(Out);
#endif
}
