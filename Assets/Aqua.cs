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
    public TextureParameter noiseTexture = new TextureParameter(null);

    #endregion

    #region Private members

    static class ShaderIDs
    {
        public static int Opacity = Shader.PropertyToID("_Opacity");
        public static int InputTexture = Shader.PropertyToID("_InputTexture");
        public static int NoiseTexture = Shader.PropertyToID("_NoiseTexture");
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
        _material.SetFloat(ShaderIDs.Opacity, opacity.value);
        _material.SetTexture(ShaderIDs.InputTexture, srcRT);
        _material.SetTexture(ShaderIDs.NoiseTexture, noiseTexture.value);
        HDUtils.DrawFullScreen(cmd, _material, destRT, null, 0);
    }

    public override void Cleanup()
      => CoreUtils.Destroy(_material);

    #endregion
}

} // namespace Kino.PostProcessing
