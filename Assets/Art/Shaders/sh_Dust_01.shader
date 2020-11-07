// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "sh_Dust_01"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_tiling("tiling", Vector) = (10,10,0,0)
		_bigTiling("bigTiling", Vector) = (1,1,0,0)
		_Color0("Color 0", Color) = (1,1,1,0)
		_Alpha("Alpha", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color0;
		uniform sampler2D _MainTex;
		uniform float2 _tiling;
		uniform sampler2D _TextureSample1;
		uniform sampler2D _TextureSample0;
		uniform float2 _bigTiling;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord3 = i.uv_texcoord * _tiling;
			float cos21 = cos( 0.007 * _Time.y );
			float sin21 = sin( 0.007 * _Time.y );
			float2 rotator21 = mul( uv_TexCoord3 - float2( 0,0 ) , float2x2( cos21 , -sin21 , sin21 , cos21 )) + float2( 0,0 );
			float4 tex2DNode1 = tex2D( _MainTex, rotator21 );
			float2 uv_TexCoord25 = i.uv_texcoord * _tiling;
			float cos24 = cos( -0.005 * _Time.y );
			float sin24 = sin( -0.005 * _Time.y );
			float2 rotator24 = mul( uv_TexCoord25 - float2( 0,0 ) , float2x2( cos24 , -sin24 , sin24 , cos24 )) + float2( 0,0 );
			float4 tex2DNode16 = tex2D( _TextureSample1, rotator24 );
			float4 blendOpSrc20 = tex2DNode1;
			float4 blendOpDest20 = tex2DNode16;
			float4 temp_output_20_0 = min( blendOpSrc20 , blendOpDest20 );
			o.Emission = ( _Color0 * temp_output_20_0 ).rgb;
			float2 uv_TexCoord14 = i.uv_texcoord * _bigTiling;
			float2 panner15 = ( 1.0 * _Time.y * float2( -0.1,0 ) + uv_TexCoord14);
			o.Alpha = ( temp_output_20_0 * tex2D( _TextureSample0, panner15 ).a * _Alpha ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
618;72.66667;1507;663;2909.262;1047.919;3.73919;True;True
Node;AmplifyShaderEditor.Vector2Node;31;-1344.7,-53.06626;Float;False;Property;_tiling;tiling;3;0;Create;True;0;0;False;0;10,10;10,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-969.5919,158.6145;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;10,10;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-960.7024,-31.67979;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;10,10;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;32;-1517.063,-547.0951;Float;False;Property;_bigTiling;bigTiling;4;0;Create;True;0;0;False;0;1,1;10,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode;24;-669.7031,162.3065;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;-0.005;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;21;-663.4019,-22.55847;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0.007;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-1279.856,-564.5465;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;15;-888.4548,-558.9465;Float;False;3;0;FLOAT2;1,1;False;2;FLOAT2;-0.1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;16;-381.1733,165.9227;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;c1a49d5bc27f17f49b8baa82dd2ef758;c1a49d5bc27f17f49b8baa82dd2ef758;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-390,-55;Float;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;c1a49d5bc27f17f49b8baa82dd2ef758;d5d5c7bda3e504b479a84c39d0c0dbbd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;215.6602,664.6693;Float;False;Property;_Alpha;Alpha;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-399.9165,-301.8429;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;382.619,-234.7893;Float;False;Property;_Color0;Color 0;7;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;20;20.4696,309.6049;Float;True;Darken;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-933.211,329.29;Float;False;Property;_rotate2;rotate2;6;0;Create;True;0;0;False;0;-0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;84.34232,28.28141;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;636.6259,4.215611;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;589.8954,381.7305;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1001.185,-206.0088;Float;False;Property;_rotate1;rotate1;5;0;Create;True;0;0;False;0;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;921.9035,148.0981;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;sh_Dust_01;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;25;0;31;0
WireConnection;3;0;31;0
WireConnection;24;0;25;0
WireConnection;21;0;3;0
WireConnection;14;0;32;0
WireConnection;15;0;14;0
WireConnection;16;1;24;0
WireConnection;1;1;21;0
WireConnection;13;1;15;0
WireConnection;20;0;1;0
WireConnection;20;1;16;0
WireConnection;23;0;1;0
WireConnection;23;1;16;0
WireConnection;26;0;22;0
WireConnection;26;1;20;0
WireConnection;19;0;20;0
WireConnection;19;1;13;4
WireConnection;19;2;33;0
WireConnection;0;2;26;0
WireConnection;0;9;19;0
ASEEND*/
//CHKSM=4DBF0764A6CAC4634F0683B657B8B085D4BF5C64