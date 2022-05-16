using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Kino.Aqua.Universal {

sealed class AquaEffectPass : ScriptableRenderPass
{
    public override void Execute
      (ScriptableRenderContext context, ref RenderingData data)
    {
        var fx = data.cameraData.camera.GetComponent<AquaEffect>();
        if (fx == null || !fx.enabled) return;

        var cmd = CommandBufferPool.Get("AquaEffect");
        Blit(cmd, ref data, fx.BlitMaterial, 0);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
}

public sealed class AquaEffectFeature : ScriptableRendererFeature
{
    AquaEffectPass _pass;

    public override void Create()
      => _pass = new AquaEffectPass
           { renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing };

    public override void AddRenderPasses
      (ScriptableRenderer renderer, ref RenderingData data)
      => renderer.EnqueuePass(_pass);
}

} // namespace Kino.Aqua.Universal
