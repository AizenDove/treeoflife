// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ANGRYMESH/Nature Pack/URP/Tree Bark Snow"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(Base)]_Glossiness("Base Smoothness", Range( 0 , 1)) = 0.5
		_OcclusionStrength("Base Tree AO", Range( 0 , 1)) = 0.5
		_BaseBarkAO("Base Bark AO", Range( 0 , 1)) = 0.5
		_BumpScale("Base Normal Intensity", Range( 0 , 2)) = 1
		_Color("Base Color", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTex("Base Albedo (A Smoothness)", 2D) = "gray" {}
		[Normal][NoScaleOffset]_BumpMap("Base NormalMap", 2D) = "bump" {}
		[NoScaleOffset]_OcclusionMap("Base AO (A Height)", 2D) = "white" {}
		[Header(Top)]_TopSmoothness("Top Smoothness", Range( 0 , 1)) = 1
		_TopUVScale("Top UV Scale", Range( 1 , 30)) = 10
		_TopIntensity("Top Intensity", Range( 0 , 1)) = 1
		_TopOffset("Top Offset", Range( 0 , 1)) = 0.5
		_TopContrast("Top Contrast", Range( 0 , 2)) = 1
		_TopArrowDirection("Top Arrow Direction", Range( 0 , 2)) = 0
		_DetailNormalMapScale("Top Normal Intensity", Range( 0 , 2)) = 1
		_TopColor("Top Color", Color) = (1,1,1,0)
		[NoScaleOffset]_TopAlbedoASmoothness("Top Albedo (A Smoothness)", 2D) = "gray" {}
		[Normal][NoScaleOffset]_TopNormalMap("Top NormalMap", 2D) = "bump" {}
		[Header(Wind Trunk (use common settings for both materials))]_WindTrunkAmplitude("Wind Trunk Amplitude", Range( 0 , 3)) = 1
		[ASEEnd]_WindTrunkStiffness("Wind Trunk Stiffness", Range( 1 , 3)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 3.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TopColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _TopUVScale;
			half _BumpScale;
			half _TopOffset;
			half _TopContrast;
			half _TopIntensity;
			half _TopArrowDirection;
			half _DetailNormalMapScale;
			half _Glossiness;
			half _TopSmoothness;
			half _BaseBarkAO;
			half _OcclusionStrength;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			sampler2D _TopAlbedoASmoothness;
			sampler2D _BumpMap;
			half AGT_SnowOffset;
			half AGT_SnowContrast;
			half AGT_SnowIntensity;
			half AGT_SnowArrow;
			sampler2D _OcclusionMap;
			half AGH_SnowMinimumHeight;
			half AGH_SnowFadeHeight;
			sampler2D _TopNormalMap;
			SAMPLER(sampler_TopAlbedoASmoothness);
			half AG_TreesAO;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g40 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g40 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g40 = _TimeParameters.x * temp_output_101_0_g40;
				float temp_output_73_0_g40 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red885 = v.ase_color.r;
				float temp_output_48_0_g40 = pow( abs( VColor_Red885 ) , _WindTrunkStiffness );
				float temp_output_28_0_g40 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g40 ) + ( ( temp_output_101_0_g40 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g40 ) ) ) * temp_output_73_0_g40 ) * temp_output_48_0_g40 );
				float temp_output_49_0_g40 = 0.0;
				float3 appendResult63_g40 = (float3(temp_output_28_0_g40 , ( ( sin( ( ( temp_output_99_0_g40 * ase_worldPos.y ) + mulTime10_g40 ) ) * temp_output_73_0_g40 ) * temp_output_49_0_g40 ) , temp_output_28_0_g40));
				half3 Output_Wind382 = mul( GetWorldToObjectMatrix(), float4( ( ( appendResult63_g40 + ( temp_output_73_0_g40 * ( temp_output_48_0_g40 + temp_output_49_0_g40 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				o.ase_texcoord7.xy = v.ase_texcoord3.xy;
				o.ase_texcoord7.zw = v.texcoord.xy;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind382;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord = v.texcoord;
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord3;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv4_MainTex176 = IN.ase_texcoord7.xy;
				float4 tex2DNode176 = tex2D( _MainTex, uv4_MainTex176 );
				float2 uv_MainTex162 = IN.ase_texcoord7.zw;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				half VColor_Blue887 = IN.ase_color.b;
				half Blend_Mask319 = ( 1.0 - VColor_Blue887 );
				float4 lerpResult187 = lerp( ( tex2DNode176 * _Color ) , ( _Color * tex2DNode162 ) , Blend_Mask319);
				float2 texCoord194 = IN.ase_texcoord7.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_195_0 = ( texCoord194 * _TopUVScale );
				float4 tex2DNode172 = tex2D( _TopAlbedoASmoothness, temp_output_195_0 );
				float2 uv4_BumpMap437 = IN.ase_texcoord7.xy;
				float3 unpack437 = UnpackNormalScale( tex2D( _BumpMap, uv4_BumpMap437 ), _BumpScale );
				unpack437.z = lerp( 1, unpack437.z, saturate(_BumpScale) );
				float2 uv_BumpMap96 = IN.ase_texcoord7.zw;
				float3 unpack96 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap96 ), _BumpScale );
				unpack96.z = lerp( 1, unpack96.z, saturate(_BumpScale) );
				float3 lerpResult321 = lerp( unpack437 , unpack96 , Blend_Mask319);
				half3 NormalMap166 = lerpResult321;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 tanNormal93 = NormalMap166;
				float3 worldNormal93 = float3(dot(tanToWorld0,tanNormal93), dot(tanToWorld1,tanNormal93), dot(tanToWorld2,tanNormal93));
				float3 tanNormal630 = NormalMap166;
				float3 worldNormal630 = float3(dot(tanToWorld0,tanNormal630), dot(tanToWorld1,tanNormal630), dot(tanToWorld2,tanNormal630));
				half3 Wind_Direction616 = AGW_WindDirection;
				float dotResult631 = dot( worldNormal630 , Wind_Direction616 );
				half GlobalSnowIntensity818 = AGT_SnowIntensity;
				float2 uv4_OcclusionMap443 = IN.ase_texcoord7.xy;
				float4 tex2DNode443 = tex2D( _OcclusionMap, uv4_OcclusionMap443 );
				float2 uv_OcclusionMap200 = IN.ase_texcoord7.zw;
				float4 tex2DNode200 = tex2D( _OcclusionMap, uv_OcclusionMap200 );
				float lerpResult553 = lerp( tex2DNode443.a , tex2DNode200.a , Blend_Mask319);
				half Blend_Height554 = lerpResult553;
				half Top_Mask168 = ( saturate( ( saturate( ( pow( abs( ( saturate( worldNormal93.y ) + ( _TopOffset * AGT_SnowOffset ) ) ) , ( (1.0 + (_TopContrast - 0.0) * (20.0 - 1.0) / (1.0 - 0.0)) * AGT_SnowContrast ) ) * ( _TopIntensity * AGT_SnowIntensity ) ) ) + ( _TopIntensity * pow( abs( ( ( 1.0 - dotResult631 ) * ( _TopArrowDirection * AGT_SnowArrow * GlobalSnowIntensity818 ) * Blend_Height554 ) ) , 30.0 ) ) ) ) * saturate( (0.0 + (WorldPosition.y - AGH_SnowMinimumHeight) * (1.0 - 0.0) / (( AGH_SnowMinimumHeight + AGH_SnowFadeHeight ) - AGH_SnowMinimumHeight)) ) );
				float4 lerpResult157 = lerp( lerpResult187 , ( tex2DNode172 * _TopColor ) , Top_Mask168);
				half4 Output_Albedo596 = lerpResult157;
				
				half2 Top_UVScale197 = temp_output_195_0;
				float3 unpack119 = UnpackNormalScale( tex2D( _TopNormalMap, Top_UVScale197 ), _DetailNormalMapScale );
				unpack119.z = lerp( 1, unpack119.z, saturate(_DetailNormalMapScale) );
				float3 lerpResult158 = lerp( lerpResult321 , BlendNormal( lerpResult321 , unpack119 ) , Top_Mask168);
				float3 normalizeResult136 = normalize( lerpResult158 );
				half3 Output_Normal598 = normalizeResult136;
				
				half Alpha_SmoothnessCH3452 = tex2DNode176.a;
				half Alpha_SmoothnessCH1212 = tex2DNode162.a;
				float lerpResult453 = lerp( Alpha_SmoothnessCH3452 , Alpha_SmoothnessCH1212 , Blend_Mask319);
				half Top_Smoothness220 = tex2DNode172.a;
				float lerpResult217 = lerp( ( lerpResult453 + (-1.0 + (_Glossiness - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , ( Top_Smoothness220 + (-1.0 + (_TopSmoothness - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , Top_Mask168);
				half Output_Smoothness223 = lerpResult217;
				
				float4 temp_cast_1 = (1.0).xxxx;
				float4 lerpResult201 = lerp( tex2DNode443 , tex2DNode200 , Blend_Mask319);
				float4 lerpResult444 = lerp( temp_cast_1 , lerpResult201 , _BaseBarkAO);
				half VColor_Alpha886 = IN.ase_color.a;
				float lerpResult335 = lerp( 1.0 , VColor_Alpha886 , ( _OcclusionStrength * AG_TreesAO ));
				half AO_BaseTree458 = saturate( lerpResult335 );
				half4 Output_AO207 = ( lerpResult444 * AO_BaseTree458 );
				
				float3 Albedo = Output_Albedo596.rgb;
				float3 Normal = Output_Normal598;
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = Output_Smoothness223;
				float Occlusion = Output_AO207.r;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TopColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _TopUVScale;
			half _BumpScale;
			half _TopOffset;
			half _TopContrast;
			half _TopIntensity;
			half _TopArrowDirection;
			half _DetailNormalMapScale;
			half _Glossiness;
			half _TopSmoothness;
			half _BaseBarkAO;
			half _OcclusionStrength;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g40 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g40 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g40 = _TimeParameters.x * temp_output_101_0_g40;
				float temp_output_73_0_g40 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red885 = v.ase_color.r;
				float temp_output_48_0_g40 = pow( abs( VColor_Red885 ) , _WindTrunkStiffness );
				float temp_output_28_0_g40 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g40 ) + ( ( temp_output_101_0_g40 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g40 ) ) ) * temp_output_73_0_g40 ) * temp_output_48_0_g40 );
				float temp_output_49_0_g40 = 0.0;
				float3 appendResult63_g40 = (float3(temp_output_28_0_g40 , ( ( sin( ( ( temp_output_99_0_g40 * ase_worldPos.y ) + mulTime10_g40 ) ) * temp_output_73_0_g40 ) * temp_output_49_0_g40 ) , temp_output_28_0_g40));
				half3 Output_Wind382 = mul( GetWorldToObjectMatrix(), float4( ( ( appendResult63_g40 + ( temp_output_73_0_g40 * ( temp_output_48_0_g40 + temp_output_49_0_g40 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind382;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TopColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _TopUVScale;
			half _BumpScale;
			half _TopOffset;
			half _TopContrast;
			half _TopIntensity;
			half _TopArrowDirection;
			half _DetailNormalMapScale;
			half _Glossiness;
			half _TopSmoothness;
			half _BaseBarkAO;
			half _OcclusionStrength;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g40 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g40 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g40 = _TimeParameters.x * temp_output_101_0_g40;
				float temp_output_73_0_g40 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red885 = v.ase_color.r;
				float temp_output_48_0_g40 = pow( abs( VColor_Red885 ) , _WindTrunkStiffness );
				float temp_output_28_0_g40 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g40 ) + ( ( temp_output_101_0_g40 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g40 ) ) ) * temp_output_73_0_g40 ) * temp_output_48_0_g40 );
				float temp_output_49_0_g40 = 0.0;
				float3 appendResult63_g40 = (float3(temp_output_28_0_g40 , ( ( sin( ( ( temp_output_99_0_g40 * ase_worldPos.y ) + mulTime10_g40 ) ) * temp_output_73_0_g40 ) * temp_output_49_0_g40 ) , temp_output_28_0_g40));
				half3 Output_Wind382 = mul( GetWorldToObjectMatrix(), float4( ( ( appendResult63_g40 + ( temp_output_73_0_g40 * ( temp_output_48_0_g40 + temp_output_49_0_g40 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind382;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TopColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _TopUVScale;
			half _BumpScale;
			half _TopOffset;
			half _TopContrast;
			half _TopIntensity;
			half _TopArrowDirection;
			half _DetailNormalMapScale;
			half _Glossiness;
			half _TopSmoothness;
			half _BaseBarkAO;
			half _OcclusionStrength;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			sampler2D _TopAlbedoASmoothness;
			sampler2D _BumpMap;
			half AGT_SnowOffset;
			half AGT_SnowContrast;
			half AGT_SnowIntensity;
			half AGT_SnowArrow;
			sampler2D _OcclusionMap;
			half AGH_SnowMinimumHeight;
			half AGH_SnowFadeHeight;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g40 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g40 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g40 = _TimeParameters.x * temp_output_101_0_g40;
				float temp_output_73_0_g40 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red885 = v.ase_color.r;
				float temp_output_48_0_g40 = pow( abs( VColor_Red885 ) , _WindTrunkStiffness );
				float temp_output_28_0_g40 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g40 ) + ( ( temp_output_101_0_g40 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g40 ) ) ) * temp_output_73_0_g40 ) * temp_output_48_0_g40 );
				float temp_output_49_0_g40 = 0.0;
				float3 appendResult63_g40 = (float3(temp_output_28_0_g40 , ( ( sin( ( ( temp_output_99_0_g40 * ase_worldPos.y ) + mulTime10_g40 ) ) * temp_output_73_0_g40 ) * temp_output_49_0_g40 ) , temp_output_28_0_g40));
				half3 Output_Wind382 = mul( GetWorldToObjectMatrix(), float4( ( ( appendResult63_g40 + ( temp_output_73_0_g40 * ( temp_output_48_0_g40 + temp_output_49_0_g40 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord3.xy;
				o.ase_texcoord2.zw = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind382;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv4_MainTex176 = IN.ase_texcoord2.xy;
				float4 tex2DNode176 = tex2D( _MainTex, uv4_MainTex176 );
				float2 uv_MainTex162 = IN.ase_texcoord2.zw;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				half VColor_Blue887 = IN.ase_color.b;
				half Blend_Mask319 = ( 1.0 - VColor_Blue887 );
				float4 lerpResult187 = lerp( ( tex2DNode176 * _Color ) , ( _Color * tex2DNode162 ) , Blend_Mask319);
				float2 texCoord194 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_195_0 = ( texCoord194 * _TopUVScale );
				float4 tex2DNode172 = tex2D( _TopAlbedoASmoothness, temp_output_195_0 );
				float2 uv4_BumpMap437 = IN.ase_texcoord2.xy;
				float3 unpack437 = UnpackNormalScale( tex2D( _BumpMap, uv4_BumpMap437 ), _BumpScale );
				unpack437.z = lerp( 1, unpack437.z, saturate(_BumpScale) );
				float2 uv_BumpMap96 = IN.ase_texcoord2.zw;
				float3 unpack96 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap96 ), _BumpScale );
				unpack96.z = lerp( 1, unpack96.z, saturate(_BumpScale) );
				float3 lerpResult321 = lerp( unpack437 , unpack96 , Blend_Mask319);
				half3 NormalMap166 = lerpResult321;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal93 = NormalMap166;
				float3 worldNormal93 = float3(dot(tanToWorld0,tanNormal93), dot(tanToWorld1,tanNormal93), dot(tanToWorld2,tanNormal93));
				float3 tanNormal630 = NormalMap166;
				float3 worldNormal630 = float3(dot(tanToWorld0,tanNormal630), dot(tanToWorld1,tanNormal630), dot(tanToWorld2,tanNormal630));
				half3 Wind_Direction616 = AGW_WindDirection;
				float dotResult631 = dot( worldNormal630 , Wind_Direction616 );
				half GlobalSnowIntensity818 = AGT_SnowIntensity;
				float2 uv4_OcclusionMap443 = IN.ase_texcoord2.xy;
				float4 tex2DNode443 = tex2D( _OcclusionMap, uv4_OcclusionMap443 );
				float2 uv_OcclusionMap200 = IN.ase_texcoord2.zw;
				float4 tex2DNode200 = tex2D( _OcclusionMap, uv_OcclusionMap200 );
				float lerpResult553 = lerp( tex2DNode443.a , tex2DNode200.a , Blend_Mask319);
				half Blend_Height554 = lerpResult553;
				half Top_Mask168 = ( saturate( ( saturate( ( pow( abs( ( saturate( worldNormal93.y ) + ( _TopOffset * AGT_SnowOffset ) ) ) , ( (1.0 + (_TopContrast - 0.0) * (20.0 - 1.0) / (1.0 - 0.0)) * AGT_SnowContrast ) ) * ( _TopIntensity * AGT_SnowIntensity ) ) ) + ( _TopIntensity * pow( abs( ( ( 1.0 - dotResult631 ) * ( _TopArrowDirection * AGT_SnowArrow * GlobalSnowIntensity818 ) * Blend_Height554 ) ) , 30.0 ) ) ) ) * saturate( (0.0 + (WorldPosition.y - AGH_SnowMinimumHeight) * (1.0 - 0.0) / (( AGH_SnowMinimumHeight + AGH_SnowFadeHeight ) - AGH_SnowMinimumHeight)) ) );
				float4 lerpResult157 = lerp( lerpResult187 , ( tex2DNode172 * _TopColor ) , Top_Mask168);
				half4 Output_Albedo596 = lerpResult157;
				
				
				float3 Albedo = Output_Albedo596.rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70201

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _TopColor;
			half _WindTrunkAmplitude;
			half _WindTrunkStiffness;
			half _TopUVScale;
			half _BumpScale;
			half _TopOffset;
			half _TopContrast;
			half _TopIntensity;
			half _TopArrowDirection;
			half _DetailNormalMapScale;
			half _Glossiness;
			half _TopSmoothness;
			half _BaseBarkAO;
			half _OcclusionStrength;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			half AGW_WindScale;
			half AGW_WindSpeed;
			half AGW_WindToggle;
			half AGW_WindAmplitude;
			half AGW_WindTreeStiffness;
			half3 AGW_WindDirection;
			sampler2D _MainTex;
			sampler2D _TopAlbedoASmoothness;
			sampler2D _BumpMap;
			half AGT_SnowOffset;
			half AGT_SnowContrast;
			half AGT_SnowIntensity;
			half AGT_SnowArrow;
			sampler2D _OcclusionMap;
			half AGH_SnowMinimumHeight;
			half AGH_SnowFadeHeight;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_99_0_g40 = ( 1.0 * AGW_WindScale );
				float temp_output_101_0_g40 = ( 1.0 * AGW_WindSpeed );
				float mulTime10_g40 = _TimeParameters.x * temp_output_101_0_g40;
				float temp_output_73_0_g40 = ( AGW_WindToggle * _WindTrunkAmplitude * AGW_WindAmplitude );
				half VColor_Red885 = v.ase_color.r;
				float temp_output_48_0_g40 = pow( abs( VColor_Red885 ) , _WindTrunkStiffness );
				float temp_output_28_0_g40 = ( ( sin( ( ( ase_worldPos.z * temp_output_99_0_g40 ) + ( ( temp_output_101_0_g40 * sin( _TimeParameters.x * 0.5 ) ) + mulTime10_g40 ) ) ) * temp_output_73_0_g40 ) * temp_output_48_0_g40 );
				float temp_output_49_0_g40 = 0.0;
				float3 appendResult63_g40 = (float3(temp_output_28_0_g40 , ( ( sin( ( ( temp_output_99_0_g40 * ase_worldPos.y ) + mulTime10_g40 ) ) * temp_output_73_0_g40 ) * temp_output_49_0_g40 ) , temp_output_28_0_g40));
				half3 Output_Wind382 = mul( GetWorldToObjectMatrix(), float4( ( ( appendResult63_g40 + ( temp_output_73_0_g40 * ( temp_output_48_0_g40 + temp_output_49_0_g40 ) * ( 1.0 * (1.0 + (AGW_WindTreeStiffness - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) ) ) * AGW_WindDirection ) , 0.0 ) ).xyz;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord3.xy;
				o.ase_texcoord2.zw = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = Output_Wind382;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv4_MainTex176 = IN.ase_texcoord2.xy;
				float4 tex2DNode176 = tex2D( _MainTex, uv4_MainTex176 );
				float2 uv_MainTex162 = IN.ase_texcoord2.zw;
				float4 tex2DNode162 = tex2D( _MainTex, uv_MainTex162 );
				half VColor_Blue887 = IN.ase_color.b;
				half Blend_Mask319 = ( 1.0 - VColor_Blue887 );
				float4 lerpResult187 = lerp( ( tex2DNode176 * _Color ) , ( _Color * tex2DNode162 ) , Blend_Mask319);
				float2 texCoord194 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_195_0 = ( texCoord194 * _TopUVScale );
				float4 tex2DNode172 = tex2D( _TopAlbedoASmoothness, temp_output_195_0 );
				float2 uv4_BumpMap437 = IN.ase_texcoord2.xy;
				float3 unpack437 = UnpackNormalScale( tex2D( _BumpMap, uv4_BumpMap437 ), _BumpScale );
				unpack437.z = lerp( 1, unpack437.z, saturate(_BumpScale) );
				float2 uv_BumpMap96 = IN.ase_texcoord2.zw;
				float3 unpack96 = UnpackNormalScale( tex2D( _BumpMap, uv_BumpMap96 ), _BumpScale );
				unpack96.z = lerp( 1, unpack96.z, saturate(_BumpScale) );
				float3 lerpResult321 = lerp( unpack437 , unpack96 , Blend_Mask319);
				half3 NormalMap166 = lerpResult321;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal93 = NormalMap166;
				float3 worldNormal93 = float3(dot(tanToWorld0,tanNormal93), dot(tanToWorld1,tanNormal93), dot(tanToWorld2,tanNormal93));
				float3 tanNormal630 = NormalMap166;
				float3 worldNormal630 = float3(dot(tanToWorld0,tanNormal630), dot(tanToWorld1,tanNormal630), dot(tanToWorld2,tanNormal630));
				half3 Wind_Direction616 = AGW_WindDirection;
				float dotResult631 = dot( worldNormal630 , Wind_Direction616 );
				half GlobalSnowIntensity818 = AGT_SnowIntensity;
				float2 uv4_OcclusionMap443 = IN.ase_texcoord2.xy;
				float4 tex2DNode443 = tex2D( _OcclusionMap, uv4_OcclusionMap443 );
				float2 uv_OcclusionMap200 = IN.ase_texcoord2.zw;
				float4 tex2DNode200 = tex2D( _OcclusionMap, uv_OcclusionMap200 );
				float lerpResult553 = lerp( tex2DNode443.a , tex2DNode200.a , Blend_Mask319);
				half Blend_Height554 = lerpResult553;
				half Top_Mask168 = ( saturate( ( saturate( ( pow( abs( ( saturate( worldNormal93.y ) + ( _TopOffset * AGT_SnowOffset ) ) ) , ( (1.0 + (_TopContrast - 0.0) * (20.0 - 1.0) / (1.0 - 0.0)) * AGT_SnowContrast ) ) * ( _TopIntensity * AGT_SnowIntensity ) ) ) + ( _TopIntensity * pow( abs( ( ( 1.0 - dotResult631 ) * ( _TopArrowDirection * AGT_SnowArrow * GlobalSnowIntensity818 ) * Blend_Height554 ) ) , 30.0 ) ) ) ) * saturate( (0.0 + (WorldPosition.y - AGH_SnowMinimumHeight) * (1.0 - 0.0) / (( AGH_SnowMinimumHeight + AGH_SnowFadeHeight ) - AGH_SnowMinimumHeight)) ) );
				float4 lerpResult157 = lerp( lerpResult187 , ( tex2DNode172 * _TopColor ) , Top_Mask168);
				half4 Output_Albedo596 = lerpResult157;
				
				
				float3 Albedo = Output_Albedo596.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	/*ase_lod*/
	
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18504
1920;89;1906;928;5008.727;3217.19;5.927113;True;False
Node;AmplifyShaderEditor.VertexColorNode;884;-2688,512;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;887;-2432,608;Half;False;VColor_Blue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;455;-2176,608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;-1984,608;Half;False;Blend_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-2688,-512;Half;False;Property;_BumpScale;Base Normal Intensity;3;0;Create;False;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;287;-2688,-384;Float;True;Property;_BumpMap;Base NormalMap;6;2;[Normal];[NoScaleOffset];Create;False;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;96;-2304,-288;Inherit;True;Property;_Test;Test;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;322;-1920,-320;Inherit;False;319;Blend_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;437;-2304,-512;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;None;True;3;True;bump;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;321;-1664,-512;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-1408,-384;Half;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-6064,512;Inherit;False;166;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-5760,864;Half;False;Property;_TopContrast;Top Contrast;12;0;Create;True;0;0;False;0;False;1;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;93;-5760,512;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;246;-5760,672;Half;False;Property;_TopIntensity;Top Intensity;10;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;114;-5376,768;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;765;-720,768;Half;False;Global;AGW_WindDirection;AGW_WindDirection;20;0;Create;True;0;0;False;0;False;0,0,0;-0.4521585,-0.3420203,0.8237566;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;277;-5760,-1408;Float;True;Property;_OcclusionMap;Base AO (A Height);7;1;[NoScaleOffset];Create;False;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;103;-5760,768;Half;False;Property;_TopOffset;Top Offset;11;0;Create;True;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;896;-5120,512;Inherit;False;AG Global Snow - Tree;-1;;37;0af770cdce085fc40bbf5b8250612a37;0;4;22;FLOAT;0;False;24;FLOAT;0;False;23;FLOAT;0;False;25;FLOAT;0;False;2;FLOAT;0;FLOAT;33
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;-256,768;Half;False;Wind_Direction;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;636;-6064,1024;Inherit;False;166;NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;200;-5376,-1088;Inherit;True;Property;_Texture;Texture;5;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;446;-5376,-1184;Inherit;False;319;Blend_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;443;-5376,-1408;Inherit;True;Property;_TextureSample5;Texture Sample 5;5;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;3;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;818;-4736,576;Half;False;GlobalSnowIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;630;-5760,1024;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;633;-5760,1216;Inherit;False;616;Wind_Direction;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;553;-4864,-1088;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;668;-5504,1152;Half;False;Property;_TopArrowDirection;Top Arrow Direction;13;0;Create;True;0;0;False;0;False;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;554;-4608,-1088;Half;False;Blend_Height;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;631;-5504,1024;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;595;-5504,1248;Half;False;Global;AGT_SnowArrow;AGT_SnowArrow;19;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;819;-5504,1344;Inherit;False;818;GlobalSnowIntensity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;555;-5213,1285;Inherit;False;554;Blend_Height;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;674;-5200,1152;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;635;-5376,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;673;-4992,1024;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;899;-4736,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;669;-4992,1152;Half;False;Constant;_FloatContrast;Float Contrast;20;0;Create;True;0;0;False;0;False;30;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;649;-4608,1024;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;885;-2432,512;Half;False;VColor_Red;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;653;-4480,672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;890;-1536,512;Inherit;False;885;VColor_Red;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;513;-4352,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;143;-4224,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;911;-4224,640;Inherit;False;AG Global Snow - Height;-1;;39;792d553d9b3743f498843a42559debdb;0;0;1;FLOAT;43
Node;AmplifyShaderEditor.RangedFloatNode;196;-2688,-1216;Half;False;Property;_TopUVScale;Top UV Scale;9;0;Create;True;0;0;False;0;False;10;1;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;438;-2688,-2176;Float;True;Property;_MainTex;Base Albedo (A Smoothness);5;1;[NoScaleOffset];Create;False;0;0;False;0;False;None;None;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;825;-1536,608;Half;False;Property;_WindTrunkStiffness;Wind Trunk Stiffness;19;0;Create;True;0;0;False;0;False;2;2;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;898;-1280,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;194;-2688,-1408;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;826;-1536,704;Half;False;Property;_WindTrunkAmplitude;Wind Trunk Amplitude;18;0;Create;True;0;0;False;1;Header(Wind Trunk (use common settings for both materials));False;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;910;-3968,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;162;-2176,-1664;Inherit;True;Property;_TextureSample4;Texture Sample 4;16;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;794;-1152,512;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;176;-2176,-2176;Inherit;True;Property;_TileAlbedo;Tile Albedo;16;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;3;False;gray;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-2432,-1360;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;165;-2176,-1952;Half;False;Property;_Color;Base Color;4;0;Create;False;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-3712,512;Half;False;Top_Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;440;-1664,-2176;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;172;-2176,-1408;Inherit;True;Property;_TopAlbedoASmoothness;Top Albedo (A Smoothness);16;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-1664,-1872;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;897;-896,512;Inherit;False;AG Global Wind - Tree;-1;;40;b3a3869a2b12ed246ae10bcce7d41e6e;0;6;48;FLOAT;0;False;49;FLOAT;0;False;96;FLOAT;1;False;94;FLOAT;1;False;95;FLOAT;1;False;97;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;175;-2176,-1088;Half;False;Property;_TopColor;Top Color;15;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;320;-1408,-1856;Inherit;False;319;Blend_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;766;-384,512;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;187;-1152,-2176;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-1664,-1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-1661.242,-1312;Inherit;False;168;Top_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;824;-256,640;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;767;0,512;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;157;-896,-1440;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;596;-640,-1440;Half;False;Output_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;382;256,512;Half;False;Output_Wind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;454;-5760,-416;Inherit;False;212;Alpha_SmoothnessCH1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-3712,-1408;Half;False;Output_AO;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;309;-5376,-64;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;-2304,-64;Inherit;True;Property;_TopNormalMap;Top NormalMap;17;2;[Normal];[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;332;-5760,-2176;Half;False;Constant;_Float2;Float 2;19;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;888;-5760,-2080;Inherit;False;886;VColor_Alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;335;-5248,-2176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-5760,-224;Half;False;Property;_Glossiness;Base Smoothness;0;0;Create;False;0;0;False;1;Header(Base);False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-5760,-512;Inherit;False;452;Alpha_SmoothnessCH3;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;520;-4864,-2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;444;-4224,-1408;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-2688,32;Half;False;Property;_DetailNormalMapScale;Top Normal Intensity;14;0;Create;False;0;0;False;0;False;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;201;-4864,-1408;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;452;-1664,-2049.351;Half;False;Alpha_SmoothnessCH3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-4608,-1216;Half;False;Property;_BaseBarkAO;Base Bark AO;2;0;Create;True;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;458;-4608,-2176;Half;False;AO_BaseTree;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-1408,32;Inherit;False;168;Top_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-5760,-128;Inherit;False;220;Top_Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-5376,-2000;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;252;-1408,-80;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-5760,-32;Half;False;Property;_TopSmoothness;Top Smoothness;8;0;Create;True;0;0;False;1;Header(Top);False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-2176,-1184;Half;False;Top_UVScale;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;598;-640,-512;Half;False;Output_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-5760,-320;Inherit;False;319;Blend_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-5120,0;Inherit;False;168;Top_Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-2688,-64;Inherit;False;197;Top_UVScale;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;158;-1152,-512;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;308;-5120,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;453;-5376,-512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;-5760,-1888;Half;False;Global;AG_TreesAO;AG_TreesAO;21;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;-3968,-1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-4608,-1312;Half;False;Constant;_White1;White1;19;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;217;-4864,-512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;597;256,-2176;Inherit;False;596;Output_Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-1664,-1600;Half;False;Alpha_SmoothnessCH1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;256,-1984;Inherit;False;223;Output_Smoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-5760,-1984;Half;False;Property;_OcclusionStrength;Base Tree AO;1;0;Create;False;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;-1664,-1219;Half;False;Top_Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-4608,-512;Half;False;Output_Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;602;256,-1888;Inherit;False;207;Output_AO;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;886;-2432,704;Half;False;VColor_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;609;-4224,-1280;Inherit;False;458;AO_BaseTree;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;599;256,-2080;Inherit;False;598;Output_Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;310;-5376,-352;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;136;-896,-512;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;-5120,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;256,-1792;Inherit;False;382;Output_Wind;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;912;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;906;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;905;640,-2176;Half;False;True;-1;2;;0;2;ANGRYMESH/Nature Pack/URP/Tree Bark Snow;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;17;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;36;Workflow;1;Surface;0;  Refraction Model;0;  Blend;0;Two Sided;1;Fragment Normal Space,InvertActionOnDeselection;0;Transmission;0;  Transmission Shadow;0.5,False,-1;Translucency;0;  Translucency Strength;1,False,-1;  Normal Distortion;0.5,False,-1;  Scattering;2,False,-1;  Direct;0.9,False,-1;  Ambient;0.1,False,-1;  Shadow;0.5,False,-1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;_FinalColorxAlpha;0;Meta Pass;1;Override Baked GI;0;Extra Pre Pass;0;DOTS Instancing;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;6;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;908;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;907;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;909;640,-2176;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.CommentaryNode;240;-2688,-640;Inherit;False;2301.541;100;;0;// Blend Normal Maps;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;241;-5760,384;Inherit;False;2299.659;100;;0;// Top World Mapping;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;600;-5760,-1536;Inherit;False;2297.873;100;;0;// AO Maps;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;210;-5760,-2304;Inherit;False;1405.242;100;;0;// AO VAlpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;230;-5760,-640;Inherit;False;1537.111;100;;0;// Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;892;256,-2304;Inherit;False;635.7682;100;;0;// Outputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;603;-2688,384;Inherit;False;3138.556;100;;0;// Vertex Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;237;-2688,-2304;Inherit;False;2311.763;100;;0;// Blend Albedo Maps;1,1,1,1;0;0
WireConnection;887;0;884;3
WireConnection;455;0;887;0
WireConnection;319;0;455;0
WireConnection;96;0;287;0
WireConnection;96;5;189;0
WireConnection;437;0;287;0
WireConnection;437;5;189;0
WireConnection;321;0;437;0
WireConnection;321;1;96;0
WireConnection;321;2;322;0
WireConnection;166;0;321;0
WireConnection;93;0;167;0
WireConnection;114;0;107;0
WireConnection;896;22;93;2
WireConnection;896;24;246;0
WireConnection;896;23;103;0
WireConnection;896;25;114;0
WireConnection;616;0;765;0
WireConnection;200;0;277;0
WireConnection;443;0;277;0
WireConnection;818;0;896;33
WireConnection;630;0;636;0
WireConnection;553;0;443;4
WireConnection;553;1;200;4
WireConnection;553;2;446;0
WireConnection;554;0;553;0
WireConnection;631;0;630;0
WireConnection;631;1;633;0
WireConnection;674;0;668;0
WireConnection;674;1;595;0
WireConnection;674;2;819;0
WireConnection;635;0;631;0
WireConnection;673;0;635;0
WireConnection;673;1;674;0
WireConnection;673;2;555;0
WireConnection;899;0;673;0
WireConnection;649;0;899;0
WireConnection;649;1;669;0
WireConnection;885;0;884;1
WireConnection;653;0;246;0
WireConnection;653;1;649;0
WireConnection;513;0;896;0
WireConnection;513;1;653;0
WireConnection;143;0;513;0
WireConnection;898;0;890;0
WireConnection;910;0;143;0
WireConnection;910;1;911;43
WireConnection;162;0;438;0
WireConnection;794;0;898;0
WireConnection;794;1;825;0
WireConnection;176;0;438;0
WireConnection;195;0;194;0
WireConnection;195;1;196;0
WireConnection;168;0;910;0
WireConnection;440;0;176;0
WireConnection;440;1;165;0
WireConnection;172;1;195;0
WireConnection;163;0;165;0
WireConnection;163;1;162;0
WireConnection;897;48;794;0
WireConnection;897;96;826;0
WireConnection;766;0;897;0
WireConnection;766;1;765;0
WireConnection;187;0;440;0
WireConnection;187;1;163;0
WireConnection;187;2;320;0
WireConnection;173;0;172;0
WireConnection;173;1;175;0
WireConnection;767;0;824;0
WireConnection;767;1;766;0
WireConnection;157;0;187;0
WireConnection;157;1;173;0
WireConnection;157;2;170;0
WireConnection;596;0;157;0
WireConnection;382;0;767;0
WireConnection;207;0;608;0
WireConnection;309;0;218;0
WireConnection;119;1;198;0
WireConnection;119;5;139;0
WireConnection;335;0;332;0
WireConnection;335;1;888;0
WireConnection;335;2;517;0
WireConnection;520;0;335;0
WireConnection;444;0;231;0
WireConnection;444;1;201;0
WireConnection;444;2;203;0
WireConnection;201;0;443;0
WireConnection;201;1;200;0
WireConnection;201;2;446;0
WireConnection;452;0;176;4
WireConnection;458;0;520;0
WireConnection;517;0;330;0
WireConnection;517;1;518;0
WireConnection;252;0;321;0
WireConnection;252;1;119;0
WireConnection;197;0;195;0
WireConnection;598;0;136;0
WireConnection;158;0;321;0
WireConnection;158;1;252;0
WireConnection;158;2;171;0
WireConnection;308;0;221;0
WireConnection;308;1;309;0
WireConnection;453;0;214;0
WireConnection;453;1;454;0
WireConnection;453;2;456;0
WireConnection;608;0;444;0
WireConnection;608;1;609;0
WireConnection;217;0;311;0
WireConnection;217;1;308;0
WireConnection;217;2;222;0
WireConnection;212;0;162;4
WireConnection;220;0;172;4
WireConnection;223;0;217;0
WireConnection;886;0;884;4
WireConnection;310;0;216;0
WireConnection;136;0;158;0
WireConnection;311;0;453;0
WireConnection;311;1;310;0
WireConnection;905;0;597;0
WireConnection;905;1;599;0
WireConnection;905;4;224;0
WireConnection;905;5;602;0
WireConnection;905;8;397;0
ASEEND*/
//CHKSM=FB439F6FB89167285007CB990C78DF2E2D7A1D15