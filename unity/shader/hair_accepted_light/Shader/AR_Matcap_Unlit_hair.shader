// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AR/AR_Matcap_Unlit_hair"
{
	Properties
	{
		[HideInInspector]_SpecColor("SpecularColor",Color)=(1,1,1,1)
		[HideInInspector] __dirty( "", Int ) = 1
		_Alpha("_FadeAlpha",Range(0,1)) = 1
	    _Gloss("Hair Specular Shiness",Range(0,1)) = 1
	    _Cutout("Cut out" ,Range(0,1)) = 0.977
		_AmbientIntensity("Ambient Intensity",Range(0.01,1)) = 0.25
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 0.25
		_DiffuseColor("SpecularColor",Color)=(1,1,1,1)
		_Diffuse("Diffuse", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_BaseColorItensity("BaseColor Itensity", Range( 0 , 1)) = 0
		_Matcap("Matcap", 2D) = "black" {}
		_HighLightIntenSity("HighLight IntenSity", Range( 0 , 1)) = 0
		_Matcap02("Matcap02", 2D) = "black" {}
		_ReflectMask("Reflect Mask", 2D) = "black" {}
		_AnisoDir("Aniso Image",2D)=""{}
		 _AnisoOffset("Aniso Offset",Range(-1,1))=0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull off
		ZTest LEqual
		lighting off
		
		

		pass
		{
			zwrite on	
			colormask 0
			 AlphaTest Greater [_Cutout]
			 SetTexture [_Diffuse]
			 {combine texture * primary,texture}
		}
		

		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 2.0
		#pragma surface surf_accept_light Acceptlit alpha:fade noshadow 

		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float2 uv_AnisoDir;

			INTERNAL_DATA
		};
		struct SurfaceAnisoOutput
		{
		 fixed3 Albedo;
		 fixed3 Normal;
		 fixed3 Emission;
		 half3 AnisoDirection;
		 half Specular;
		 fixed Gloss;
		 fixed Alpha;
		 float AnisoOffset;
		 float Shiness;
		};

		uniform sampler2D _Diffuse;
		uniform sampler2D _AnisoDir;
		uniform float _AnisoOffset;
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
		uniform float _MaskClipValue;
		float _Gloss;
		float _Alpha;
		float _AmbientIntensity;
		fixed4 _DiffuseColor;

	
		inline half4 LightingUnlit (SurfaceAnisoOutput s ,half3 lightDir, half3 viewDir,half atten)
		{
			half3 h=normalize(lightDir + viewDir);
			half nh = max(0,dot(normalize(s.Normal + s.AnisoDirection*0.8),h));//offset normal
			half aniso = max(0, sin(radians(nh + s.AnisoOffset) * 180));
			half spec = pow(aniso,0.5*16)*s.Shiness;
			half4 c;
			c.rgb = s.Albedo + half3(1,1,1) * spec;
			c.a =s.Alpha;
			return c;
		}

		void surf( Input i , inout SurfaceAnisoOutput o )
		{
			o.Normal = float3(0,0,1);
			o.Shiness = _Gloss;
			o.AnisoOffset =  _AnisoOffset;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			fixed3 temp_cast_1 = 0.5;
			fixed3 temp_cast_4 = 0.5;
			float2 uv_ReflectMask = i.uv_texcoord * _ReflectMask_ST.xy + _ReflectMask_ST.zw;
			o.AnisoDirection = UnpackNormal(tex2D(_AnisoDir,i.uv_AnisoDir));
			o.Emission = lerp( ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity *_DiffuseColor ) + ( tex2D( _Matcap,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_1 ).xy) * _BaseColorItensity ) ) , ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity ) + ( tex2D( _Matcap02,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_4 ).xy) * _HighLightIntenSity ) ) , pow( tex2D( _ReflectMask,uv_ReflectMask) , 1.8 ).x ).xyz;
			o.Alpha = tex2D( _Diffuse,uv_Diffuse).a;
			//clip(tex2D( _Diffuse,uv_Diffuse).a - _MaskClipValue);
		}

		inline half4 LightingAcceptlit (SurfaceAnisoOutput s ,half3 lightDir, half3 viewDir,half atten)
		{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _AmbientIntensity;

			fixed3 worldNormal = normalize(s.Normal);
			half3 halfDir = normalize(lightDir + viewDir);
			fixed3 specular =  _DiffuseIntensity * _LightColor0.rgb * _DiffuseColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
			
			fixed diffuse = s.Albedo * _LightColor0.rgb * _DiffuseIntensity;

			half4 c;
			c.rgb = (ambient +  diffuse + specular)*atten;
			c.a =s.Alpha * _Alpha;
			return c;
		}

		void surf_accept_light( Input i , inout SurfaceAnisoOutput o )
		{
			o.Normal = float3(0,0,1);
			o.Shiness = _Gloss;
			o.AnisoOffset =  _AnisoOffset;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			fixed3 temp_cast_1 = 0.5;
			fixed3 temp_cast_4 = 0.5;
			float2 uv_ReflectMask = i.uv_texcoord * _ReflectMask_ST.xy + _ReflectMask_ST.zw;
			o.AnisoDirection = UnpackNormal(tex2D(_AnisoDir,i.uv_AnisoDir));
			o.Emission = lerp( ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity *_DiffuseColor ) + ( tex2D( _Matcap,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_1 ).xy) * _BaseColorItensity ) ) , ( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIntensity ) + ( tex2D( _Matcap02,( ( mul( UNITY_MATRIX_V , fixed4( WorldNormalVector( i , UnpackNormal( tex2D( _Normal,uv_Normal) ) ) , 0.0 ) ) * 0.5 ) + temp_cast_4 ).xy) * _HighLightIntenSity ) ) , pow( tex2D( _ReflectMask,uv_ReflectMask) , 1.8 ).x ).xyz ;
			o.Alpha = tex2D( _Diffuse,uv_Diffuse).a ;
			//clip(tex2D( _Diffuse,uv_Diffuse).a - _MaskClipValue);
		}
		
		
		

		ENDCG

	}

}
