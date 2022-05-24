using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using Kino.Aqua;

namespace Kino.PostProcessing {

[System.Serializable]
[VolumeComponentMenu("Post-processing/Kino/Aqua")]
public sealed class Aqua
  : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    #region Effect parameters

    public ClampedFloatParameter opacity
      = new ClampedFloatParameter(0, 0, 1);

    [Space]

    public ColorParameter edgeColor
      = new ColorParameter(Color.black);

    public ClampedFloatParameter edgeContrast
      = new ClampedFloatParameter(1.2f, 0.01f, 4);

    [Space]

    public ColorParameter fillColor
      = new ColorParameter(Color.white);

    public ClampedFloatParameter blurWidth
      = new ClampedFloatParameter(1, 0, 2);

    public ClampedFloatParameter blurFrequency
      = new ClampedFloatParameter(0.5f, 0, 1);

    public ClampedFloatParameter hueShift
      = new ClampedFloatParameter(0.1f, 0, 0.3f);

    [Space]

    public ClampedFloatParameter interval
      = new ClampedFloatParameter(1, 0.1f, 5);

    public ClampedIntParameter iteration
      = new ClampedIntParameter(20, 4, 32);

    [Space]

    public VolumeParameter<OverlayMode> overlayMode
      = new VolumeParameter<OverlayMode>();

    public NoInterpTextureParameter overlayTexture
      = new NoInterpTextureParameter(null);

    public ClampedFloatParameter overlayOpacity
      = new ClampedFloatParameter(0, 0, 1);

    #endregion

    #region Private members

    static readonly string ShaderName
      = "Hidden/Kino/Aqua/HighDefinition";

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
      => _material = CoreUtils.CreateEngineMaterial(ShaderName);

    public override void Render
      (CommandBuffer cmd, HDCamera camera, RTHandle srcRT, RTHandle destRT)
    {
        ShaderHelper.SetProperties
          (_material, srcRT,
           opacity: opacity.value,
           edgeColor: edgeColor.value,
           edgeContrast: edgeContrast.value,
           fillColor: fillColor.value,
           blurWidth: blurWidth.value,
           blurFrequency: blurFrequency.value,
           hueShift: hueShift.value,
           interval: interval.value,
           iteration: iteration.value);

        ShaderHelper.SetOverlayProperties
          (_material,
           overlayMode.value,
           overlayTexture.value,
           overlayOpacity.value);

        HDUtils.DrawFullScreen(cmd, _material, destRT, null, 0);
    }

    public override void Cleanup()
      => CoreUtils.Destroy(_material);

    #endregion
}

} // namespace Kino.Aqua.HighDefinition
