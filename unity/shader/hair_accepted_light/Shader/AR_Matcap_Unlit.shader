// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AR/AR_Matcap_Unlit"
{
	Properties
	{
		[HideInInspector]_SpecColor("SpecularColor",Color)=(1,1,1,1)
		[HideInInspector] __dirty( "", Int ) = 1
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 0
		_Diffuse("Diffuse", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_BaseColorItensity("BaseColor Itensity", Range( 0 , 1)) = 0
		_Matcap("Matcap", 2D) = "black" {}
		_HighLightIntenSity("HighLight IntenSity", Range( 0 , 1)) = 0
		_Matcap02("Matcap02", 2D) = "black" {}
		_ReflectMask("Reflect Mask", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 2.0
		#pragma surface surf Unlit keepalpha  noshadow 
		inline half4 LightingUnlit (SurfaceOutput s, fixed3 lightDir,fixed atten)
		{
		half4 c;
		c.rgb = s.Albedo;
		c.a =s.Alpha;
		return c;
		}
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform fixed _DiffuseIntensity;
		uniform sampler2D _Matcap;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform fixed _BaseColorItensity;
		uniform sampler2D _Matcap02;
		uniform fixed _HighLightIntenSity;
		uniform sampler2D _ReflectMask;
		uniform float4 _ReflectMask_ST;

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			fixed3 temp_cast_1 = 0.5;
			fixed3 temp_cast_4 = 0.5;
			float2 uv_ReflectMask = i.uv_texcoord * _ReflectMask_ST.xy + _ReflectMask_ST.zw;
			o.Emission = lerp( ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity ) + ( tex2D( _Matcap,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_1 ).xy) * _BaseColorItensity ) ) , ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity ) + ( tex2D( _Matcap02,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_4 ).xy) * _HighLightIntenSity ) ) , pow( tex2D( _ReflectMask,uv_ReflectMask) , 1.8 ).x ).xyz;
			o.Alpha = 1;
		}

		ENDCG
	}

}
