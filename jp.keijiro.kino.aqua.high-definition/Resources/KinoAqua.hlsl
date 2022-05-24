#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

#define KINO_AQUA_INPUT_TEXTURE(x) TEXTURE2D_X(x)
#define KINO_AQUA_NOISE_TEXTURE(x) TEXTURE2D(x)

#define KINO_AQUA_SAMPLE_INPUT_TEXTURE(p) \
  SAMPLE_TEXTURE2D_X(inputTexture, s_linear_clamp_sampler, \
                     ClampAndScaleUVForBilinear(p))

#define KINO_AQUA_SAMPLE_NOISE_TEXTURE(p) \
  SAMPLE_TEXTURE2D(noiseTexture, s_linear_repeat_sampler, p)

#include "Packages/jp.keijiro.kino.aqua/Shaders/KinoAquaFilter.hlsl"

TEXTURE2D_X(_MainTex);
TEXTURE2D(_NoiseTexture);
TEXTURE2D(_OverlayTexture);

float4 _EffectParams1;
float2 _EffectParams2;
float4 _EdgeColor;
float4 _FillColor;
uint _Iteration;
float _OverlayOpacity;

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

float4 Fragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;

    KinoAquaFilter aqua;

    aqua.inputTexture = _MainTex;
    aqua.noiseTexture = _NoiseTexture;

    aqua.edgeColor = _EdgeColor;
    aqua.fillColor = _FillColor;

    aqua.aspectRatio = _ScreenSize.x / _ScreenSize.y;
    aqua.aspectRatioRcp = 1 / aqua.aspectRatio;

    aqua.iteration = _Iteration;
    aqua.iterationRcp = 1.0 / _Iteration;

    float opacity      = _EffectParams1.x;
    aqua.interval      = _EffectParams1.y;
    aqua.blurWidth     = _EffectParams1.z;
    aqua.blurFrequency = _EffectParams1.w;
    aqua.edgeContrast  = _EffectParams2.x;
    aqua.hueShift      = _EffectParams2.y;

    // Main effect
    float3 res = aqua.ProcessAt(uv);

    // Overlay blending in sRGB
    float3 ovr = SAMPLE_TEXTURE2D(_OverlayTexture, s_linear_repeat_sampler, uv).rgb;

    res = LinearToSRGB(res);
    ovr = LinearToSRGB(ovr);

    res = KinoAquaOverlay(res, ovr, _OverlayOpacity);

    res = SRGBToLinear(res);

    // Source/effect blending
    float4 src = LOAD_TEXTURE2D_X(_MainTex, uv * _ScreenSize.xy);
    return float4(lerp(src.rgb, res, opacity), src.a);
}
