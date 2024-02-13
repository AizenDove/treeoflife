using Mewlist;
using Mewlist.MassiveClouds;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public sealed class MassiveCloudsUniversalRPScriptableRenderPass : ScriptableRenderPass, IFullScreenDrawable
{
    const string RenderMassiveCloudsTag = "Render MassiveClouds";

    private ScriptableRenderer currentRenderer;
    private RenderTargetIdentifier currentTarget;
    private RenderTargetIdentifier currentDepthTarget;
    private AbstractMassiveClouds massiveCloudsRenderer;
    private DynamicRenderTexture screenTexture;
    private MassiveCloudsSunLightSource sunLightSource;
    private bool drawOnSceneView;

    public MassiveCloudsUniversalRPScriptableRenderPass()
    {
        renderPassEvent = RenderPassEvent.AfterRenderingSkybox;
    }

    public void SetRenderPassEvent(RenderPassEvent e)
    {
        renderPassEvent = e;
    }

    public void SetDrawOnSceneView(bool value)
    {
        drawOnSceneView = value;
    }

    public void SetMassiveCloudsRenderer(AbstractMassiveClouds massiveCloudsRenderer)
    {
        this.massiveCloudsRenderer = massiveCloudsRenderer;
    }
    
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!massiveCloudsRenderer) return;

        var commandBuffer = CommandBufferPool.Get(RenderMassiveCloudsTag);
        if (commandBuffer == null) return;

        var camera = renderingData.cameraData.camera;

        if (screenTexture == null)
        {
            var formatAlpha = camera.allowHDR
                              ? RenderTextureFormat.DefaultHDR
                              : RenderTextureFormat.Default;
            screenTexture = new DynamicRenderTexture(formatAlpha);
        }

        var isSceneCamera = camera.cameraType == CameraType.SceneView;
        var isReflectionProbesCamera = camera.cameraType == CameraType.Reflection;
        if (isSceneCamera)
        {
            if (!drawOnSceneView) return;
        }
        else if (!isReflectionProbesCamera)
        {
            if (!camera.GetComponent<MassiveCloudsUniversalRPCameraTarget>()) return;
        }

        screenTexture.Update(camera, CreateRenderTextureDesc(camera));

        SetCameraMatrices(commandBuffer, camera, ref renderingData.cameraData, true);

        if (!sunLightSource)
        {
            sunLightSource = Object.FindObjectOfType<MassiveCloudsSunLightSource>();
        }

        currentTarget = currentRenderer.cameraColorTarget;
#if UNITY_2020_2_OR_NEWER
        currentDepthTarget = currentRenderer.cameraDepthTarget;
#else
        currentDepthTarget = currentRenderer.cameraDepth;
#endif
        ConfigureTarget(BuiltinRenderTextureType.CameraTarget);
        massiveCloudsRenderer.UpdateClouds(sunLightSource ? sunLightSource.Light : null, null);
        commandBuffer.Blit(currentTarget, screenTexture.GetRenderTexture(camera));
        commandBuffer.SetGlobalFloat("_MassiveCloudsProbeScale", 1f);
        commandBuffer.SetGlobalFloat("_SkyIntensity", 1.0f);
        var ctx = CreateMassiveCloudsPassContext(commandBuffer, camera, screenTexture.GetRenderTexture(camera));
        massiveCloudsRenderer.BuildCommandBuffer(ctx, this);
        context.ExecuteCommandBuffer(commandBuffer);
        commandBuffer.SetRenderTarget(currentTarget, currentDepthTarget);
        CommandBufferPool.Release(commandBuffer);
    }

    private RenderTextureDesc CreateRenderTextureDesc(Camera camera)
    {
        return new RenderTextureDesc(camera.pixelWidth, camera.pixelHeight);
    }

    private MassiveCloudsPassContext CreateMassiveCloudsPassContext(
        CommandBuffer commandBuffer,
        Camera camera,
        Texture source)
    {
        var colorBufferDesc = new RenderTextureDesc(camera.pixelWidth, camera.pixelHeight);
        return new MassiveCloudsPassContext(
            commandBuffer,
            camera,
            colorBufferDesc,
            source);
    }


    // WorkAround for URP 7.4 or 8.0 unity_CameraToWorld z inversed. 
    private static readonly int cameraToWorldMatrix = Shader.PropertyToID("unity_CameraToWorld");
    private static void SetCameraMatrices(CommandBuffer cmd, Camera camera, ref CameraData cameraData,
        bool setInverseMatrices)
    {
        if (XRGraphics.enabled)
            return;
        Matrix4x4 viewMatrix = camera.cameraToWorldMatrix;
        if (setInverseMatrices)
        {
            viewMatrix.m02 = -viewMatrix.m02;
            viewMatrix.m12 = -viewMatrix.m12;
            viewMatrix.m22 = -viewMatrix.m22;
            Matrix4x4 inverseViewMatrix = Matrix4x4.Inverse(viewMatrix);
            cmd.SetGlobalMatrix(cameraToWorldMatrix, viewMatrix);
        }
    }

    public void Dispose()
    {
        if (massiveCloudsRenderer)
            massiveCloudsRenderer.Clear();
        
        if (screenTexture != null)
            screenTexture.Dispose();
        screenTexture = null;
    }

    public void SetRenderer(ScriptableRenderer renderer)
    {
        currentRenderer = renderer;
    }

    public void Draw(CommandBuffer commandBuffer, RenderTargetIdentifier source)
    {
        CommandBufferUtility.BlitProcedural(commandBuffer, source, currentTarget);
    }
}