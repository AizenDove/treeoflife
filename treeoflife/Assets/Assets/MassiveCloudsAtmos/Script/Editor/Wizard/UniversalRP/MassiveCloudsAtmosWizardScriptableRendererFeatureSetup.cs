using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Mewlist.MassiveClouds
{
    internal static class MassiveCloudsAtmosWizardScriptableRendererFeatureSetup
    {
        public static void Setup()
        {
            var pipelineAsset            = GraphicsSettings.renderPipelineAsset as UniversalRenderPipelineAsset;
            var serializedObject         = new SerializedObject(pipelineAsset);
            var rendererDataList         = new List<ScriptableRendererData>();
            var feature                  = (MassiveCloudsUniversalRPScriptableRendererFeature)null;
            var rendererDataListProperty = serializedObject.FindProperty("m_RendererDataList");

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel("Pipeline Asset");
                if (pipelineAsset == null)
                {
                    MassiveCloudsAtmosWizard.Ng("Exception");
                    return;
                }
                else
                {
                    MassiveCloudsAtmosWizard.Ok("Ok");
                    EditorGUILayout.ObjectField(pipelineAsset, typeof(RenderPipelineAsset), false);
                }
            }

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel("DepthTexture Support");
                if (!pipelineAsset.supportsCameraDepthTexture)
                {
                    MassiveCloudsAtmosWizard.Ng("Disabled");
                    if (MassiveCloudsAtmosWizard.FixButton("Fix now"))
                    {
                        pipelineAsset.supportsCameraDepthTexture = true;
                        EditorUtility.SetDirty(pipelineAsset);
                    }
                }
                else
                {
                    MassiveCloudsAtmosWizard.Ok("Ok");
                }
            }

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel("Renderer Feature");

                for (var i = 0; i < rendererDataListProperty.arraySize; i++)
                {
                    var rendererData = rendererDataListProperty.GetArrayElementAtIndex(i);
                    rendererDataList.Add(rendererData.objectReferenceValue as ScriptableRendererData);
                }


                if (rendererDataList
                    .Any(x => x != null && x.rendererFeatures
                        .Any(f => f is MassiveCloudsUniversalRPScriptableRendererFeature)))
                {
                    feature = rendererDataList.SelectMany(x => x.rendererFeatures)
                        .Where(x => x is MassiveCloudsUniversalRPScriptableRendererFeature)
                        .Cast<MassiveCloudsUniversalRPScriptableRendererFeature>()
                        .First();
                    MassiveCloudsAtmosWizard.Ok("Ok");
                    EditorGUILayout.ObjectField(feature, typeof(MassiveCloudsUniversalRPScriptableRendererFeature), false);
                }
                else
                {
                    var rendererData = rendererDataList.First();
                    if (rendererData == null)
                    {
                        MassiveCloudsAtmosWizard.Ng("Please set RendererData into PipelineAsset");
                        if (MassiveCloudsAtmosWizard.FixButton("Fix now"))
                        {
                            var property = rendererDataListProperty.GetArrayElementAtIndex(0);
                            var guid = AssetDatabase.FindAssets("t:ScriptableRendererData").First();
                            var path = AssetDatabase.GUIDToAssetPath(guid);
                            rendererData = AssetDatabase.LoadAssetAtPath<ScriptableRendererData>(path);
                            property.objectReferenceValue = rendererData;
                            serializedObject.ApplyModifiedProperties();
                        }
                    }
                    else
                    {
                        MassiveCloudsAtmosWizard.Ng("Not Installed");
                        if (MassiveCloudsAtmosWizard.SetupButton("Install"))
                        {
                            feature = ScriptableObject.CreateInstance<MassiveCloudsUniversalRPScriptableRendererFeature>();
                            rendererData.rendererFeatures.Add(feature);
                            AssetDatabase.AddObjectToAsset(feature, rendererData);
                            rendererData.SetDirty();
                            EditorUtility.SetDirty(feature);
                            EditorUtility.SetDirty(rendererData);
                        }
                    }
                }
            }

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel("Camera Component");
                var target = GameObject.FindObjectOfType<MassiveCloudsUniversalRPCameraTarget>();
                if (target)
                {
                    MassiveCloudsAtmosWizard.Ok("Ok");
                }
                else
                {
                    MassiveCloudsAtmosWizard.Ng("Add component on MainCamera");
                    if (MassiveCloudsAtmosWizard.FixButton("Fix Now"))
                    {
                        var mainCamera = Camera.main;
                        mainCamera.gameObject.AddComponent<MassiveCloudsUniversalRPCameraTarget>();
                    }
                }
            }

            if (feature != null)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    var color = GUI.color;
                    AbstractMassiveClouds renderer = null;
                    EditorGUILayout.PrefixLabel("MassiveClouds Renderer");
                    if (feature.MassiveCloudsRenderer == null)
                    {
                        GUI.color = new Color(1f, 0.6f, 0.6f, 1f);
                        MassiveCloudsAtmosWizard.Ng("Set Massive Clouds Renderer");
                    }
                    else
                    {
                        renderer = feature.MassiveCloudsRenderer;
                        MassiveCloudsAtmosWizard.Ok("Ok");
                    }
                    var serializedFeatureObject = new SerializedObject(feature);
                    serializedFeatureObject.FindProperty("MassiveCloudsRenderer").objectReferenceValue
                        = EditorGUILayout.ObjectField(renderer, typeof(AbstractMassiveClouds), false) as AbstractMassiveClouds;
                    GUI.color = color;
                    serializedFeatureObject.ApplyModifiedProperties();
                }

                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUILayout.PrefixLabel("Sun Light Source");
                    var lightSource = Object.FindObjectOfType<MassiveCloudsSunLightSource>();
                    if (!lightSource)
                    {
                        MassiveCloudsAtmosWizard.Ng("Ng");
                        if (MassiveCloudsAtmosWizard.FixButton("Fix Now"))
                        {
                            var lights = Object.FindObjectsOfType<Light>().Where(x => x.type == LightType.Directional)
                                .OrderByDescending(x => x.intensity).ToArray();
                            if (lights.Any())
                            {
                                var light = lights.First();
                                light.gameObject.AddComponent<MassiveCloudsSunLightSource>();
                                EditorUtility.SetDirty(light);
                            }
                        }
                    }
                    else
                    {
                        MassiveCloudsAtmosWizard.Ok("Ok");
                        EditorGUILayout.ObjectField(lightSource, typeof(MassiveCloudsSunLightSource), true);
                    }
                }

                MassiveCloudsEditorGUI.SectionSpace();
                MassiveCloudsEditorGUI.Header("Uninstall", 2);
                MassiveCloudsEditorGUI.Space();

                using (new EditorGUILayout.HorizontalScope())
                {
                    GUILayout.Label("");
                    if (GUILayout.Button("Uninstall"))
                    {
                        foreach (var rendererData in rendererDataList)
                        {
                            for (var i = rendererData.rendererFeatures.Count - 1; i >= 0; i--)
                            {
                                var massiveCloudsFeature = rendererData.rendererFeatures[i] as MassiveCloudsUniversalRPScriptableRendererFeature;
                                if (massiveCloudsFeature != null)
                                {
                                    AssetDatabase.RemoveObjectFromAsset(massiveCloudsFeature);
                                    rendererData.rendererFeatures.RemoveAt(i);
                                    rendererData.SetDirty();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}