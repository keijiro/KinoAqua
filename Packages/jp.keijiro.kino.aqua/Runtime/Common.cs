using UnityEngine;

namespace Kino.Aqua {

static class CommonAssets
{
    static Texture2D LoadNoiseTexture()
      => Resources.Load<Texture2D>("KinoAquaNoise");

    static Texture2D _noiseTexture;

    public static Texture2D NoiseTexture
      => _noiseTexture = _noiseTexture ?? LoadNoiseTexture();
}

static class ShaderIDs
{
    public static int EffectParams1 = Shader.PropertyToID("_EffectParams1");
    public static int EffectParams2 = Shader.PropertyToID("_EffectParams2");
    public static int EdgeColor = Shader.PropertyToID("_EdgeColor");
    public static int FillColor = Shader.PropertyToID("_FillColor");
    public static int Iteration = Shader.PropertyToID("_Iteration");
    public static int MainTex = Shader.PropertyToID("_MainTex");
    public static int NoiseTexture = Shader.PropertyToID("_NoiseTexture");
}

public static class ShaderHelper
{
    public static void SetProperties
      (Material material,
       Texture inputTexture,
       float opacity,
       Color edgeColor,
       float edgeContrast,
       Color fillColor,
       float blurWidth,
       float blurFrequency,
       float hueShift,
       float interval,
       int iteration)
    {
        var bfreq = Mathf.Exp((blurFrequency - 0.5f) * 6);

        material.SetVector(ShaderIDs.EffectParams1,
          new Vector4(opacity, interval,blurWidth, bfreq));

        material.SetVector(ShaderIDs.EffectParams2,
          new Vector2(edgeContrast, hueShift));

        material.SetColor(ShaderIDs.EdgeColor, edgeColor);
        material.SetColor(ShaderIDs.FillColor, fillColor);
        material.SetInt(ShaderIDs.Iteration, iteration);

        material.SetTexture(ShaderIDs.MainTex, inputTexture);
        material.SetTexture(ShaderIDs.NoiseTexture, CommonAssets.NoiseTexture);
    }
}

} // namespace Kino.Aqua
