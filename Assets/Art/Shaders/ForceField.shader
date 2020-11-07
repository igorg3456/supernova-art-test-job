Shader "Custom/ForceField"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    
		_Fresnel_pow("Fresnel power", float) = 2
		_Fresnel_scale("Fresnel scale", float) = 1
		_ScrollSpeed("Scroll speed", float) = 1
			

		_Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
		Blend One One
		ZWrite Off
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:blend keepalpha

        // Use shader model 2.0 target, to get nicer looking lighting
		#pragma target 2.0

        sampler2D _MainTex;

        struct Input
        {
			fixed3 viewDir;
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		fixed  _Fresnel_pow;
		fixed  _Fresnel_scale;
		fixed _ScrollSpeed;
		
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			fixed offsetX = _ScrollSpeed * _Time;
			fixed offsetY = _ScrollSpeed * _Time;
			fixed2 offsetUV = fixed2(offsetX, offsetY);

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex + offsetUV);
			
			fixed clear_fresnel = (1.0 - dot(normalize(IN.viewDir), o.Normal));
			fixed fresnel = _Fresnel_scale * pow(clear_fresnel, _Fresnel_pow);

			//o.Albedo = _Color;
			o.Emission = c.rgb * _Color.rgb;
			o.Alpha = c.rgb * _Color.a * fresnel;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
