using Mewlist.MassiveClouds;
using UnityEngine;
using UnityEngine.Rendering.Universal;

[CreateAssetMenu(fileName = "MassiveCloudsUniversalRPScriptableRendererFeature",
    menuName = "MassiveClouds/UniversalRPScriptableRendererFeature", order = 1)]
public class MassiveCloudsUniversalRPScriptableRendererFeature : ScriptableRendererFeature
{
    [SerializeField] private RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
    [SerializeField] private bool drawOnSceneView = true;
    [SerializeField] public AbstractMassiveClouds MassiveCloudsRenderer;

    private MassiveCloudsUniversalRPScriptableRenderPass currentPass;
    public override void Create()
    {
        name = "MassiveClouds UniversalRP";
        if (currentPass != null)
            Clear();

        currentPass = new MassiveCloudsUniversalRPScriptableRenderPass();
        currentPass.SetRenderPassEvent(renderPassEvent);
        currentPass.SetMassiveCloudsRenderer(MassiveCloudsRenderer);
    }

    private void OnDisable()
    {
    }

    private void Clear()
    {
        if (currentPass != null)
        {
            currentPass.Dispose();
            currentPass = null;
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        currentPass.SetDrawOnSceneView(drawOnSceneView);
        currentPass.SetRenderer(renderer);
        renderer.EnqueuePass(currentPass);
    }
}