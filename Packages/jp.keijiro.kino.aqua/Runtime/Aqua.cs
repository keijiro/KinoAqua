using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using SerializableAttribute = System.SerializableAttribute;

namespace Kino.PostProcessing {

[Serializable, VolumeComponentMenu("Post-processing/Kino/Aqua")]
public sealed class Aqua : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    #region Effect parameters

    public ClampedFloatParameter opacity = new ClampedFloatParameter(0, 0, 1);
    public ClampedFloatParameter noiseFrequency = new ClampedFloatParameter(1, 0, 2);
    public ClampedFloatParameter noiseStrength = new ClampedFloatParameter(1, 0, 2);
    public ClampedFloatParameter blurWidth = new ClampedFloatParameter(1, 0, 2);
    public ClampedFloatParameter hueShift = new ClampedFloatParameter(0.1f, 0, 0.3f);
    public ClampedFloatParameter edgeContrast = new ClampedFloatParameter(1, 0, 4);
    public TextureParameter noiseTexture = new TextureParameter(null);

    #endregion

    #region Private members

    static class ShaderIDs
    {
        public static int Opacity = Shader.PropertyToID("_Opacity");
        public static int InputTexture = Shader.PropertyToID("_InputTexture");
        public static int NoiseTexture = Shader.PropertyToID("_NoiseTexture");
        public static int EffectParams1 = Shader.PropertyToID("_EffectParams1");
        public static int EffectParams2 = Shader.PropertyToID("_EffectParams2");
    }

    Material _material;

    #endregion

    #region IPostProcessComponent implementation

    public bool IsActive()
      => _material != null && opacity.value > 0;

    #endregion

    #region CustomPostProcessVolumeComponent implementation

    public override CustomPostProcessInjectionPoint injectionPoint
      => CustomPostProcessInjectionPoint.AfterPostProcess;

    public override void Setup()
      => _material = CoreUtils.CreateEngineMaterial
                       ("Hidden/Kino/PostProcess/Aqua");

    public override void Render
      (CommandBuffer cmd, HDCamera camera, RTHandle srcRT, RTHandle destRT)
    {
        var p1 = new Vector2(noiseFrequency.value, noiseStrength.value);
        var p2 = new Vector3(blurWidth.value, hueShift.value, edgeContrast.value);

        _material.SetFloat(ShaderIDs.Opacity, opacity.value);
        _material.SetVector(ShaderIDs.EffectParams1, p1);
        _material.SetVector(ShaderIDs.EffectParams2, p2);
        _material.SetTexture(ShaderIDs.InputTexture, srcRT);
        _material.SetTexture(ShaderIDs.NoiseTexture, noiseTexture.value);

        HDUtils.DrawFullScreen(cmd, _material, destRT, null, 0);
    }

    public override void Cleanup()
      => CoreUtils.Destroy(_material);

    #endregion
}

} // namespace Kino.PostProcessing
