Shader "DiffSpecular" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_SpecMap ("Specularmap", 2D) = "white" {}
	_Shininess ("Shininess", Range (0.01, 1)) = 0.01
	_Color ("Main Color", Color) = (1,1,1,1)
	_RimPower ("Emission Power", Float) = 10
	_RimColor("Rim Color", Color) = (0,0.9294,0.9725,1)
	_RimColor2("Rim Color2", Color) = (0.9294,0.9725,0,1)
	_RimPowerX ("RimPowerX" , Float) = 1 
	_RimPowerY ("RimPowerY" , Float) = 1 
	_RimPowerZ ("RimPowerZ" , Float) = 1
	_RimTex ("Rim (RGB)", 2D) = "white" {}
}

CGINCLUDE
sampler2D _MainTex;
sampler2D _SpecMap;
sampler2D _RimTex;
half _Shininess;
fixed4 _Color;
fixed _RimPower;   
fixed4 _RimColor;
fixed4 _RimColor2;
float _RimPowerX;
float _RimPowerY;
float _RimPowerZ;

struct Input {
	float2 uv_MainTex;
	float3 viewDir;
	float3 worldPos;
	float3 worldNormal;INTERNAL_DATA
};

inline fixed4 LightingCustomBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)   
{  
	half3 h = normalize (lightDir + viewDir);
	
	fixed diff = max (0, dot (s.Normal, lightDir));

	float nh = max (0, dot (s.Normal, h));
	float spec = pow (nh, s.Specular*128.0) * s.Gloss;
	
	fixed4 c;
	c.rgb = s.Albedo * diff * _LightColor0.rgb * atten   + _SpecColor.rgb * spec;
	c.a = s.Alpha;
    return c;  
}  

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 c = tex * _Color;
	o.Albedo = c.rgb;
	fixed4 spec = tex2D(_SpecMap, IN.uv_MainTex);
	o.Gloss = 1 - spec.a;
	o.Alpha = c.a;
	o.Specular = _Shininess;
	_SpecColor = spec;
	half rim = 1.0 - saturate(dot(normalize(IN.viewDir), IN.worldNormal));
	float3 _RimPowerDirLeft = float3(IN.worldPos.x - _RimPowerX,_RimPowerY,_RimPowerZ);
	float3 _RimPowerDirRight = float3(IN.worldPos.x + _RimPowerX,_RimPowerY,_RimPowerZ);
	half rimLeft = 1.0 - saturate(dot(normalize(IN.worldNormal),normalize(_RimPowerDirLeft)));
	half rimRight = 1.0 - saturate(dot(normalize(IN.worldNormal),normalize(_RimPowerDirRight)));
	fixed4 rimCol = tex2D(_RimTex, IN.uv_MainTex);
	o.Emission = c.rgb + _RimColor2.rgb * pow (rim, _RimPower)*pow (rimLeft, _RimPower)*rimCol.a + _RimColor.rgb * pow (rim, _RimPower)*pow (rimRight, _RimPower)*rimCol.a;
}

ENDCG

SubShader { 
	Tags { "RenderType"="Opaque" }
	
	LOD 400
	Cull Off

	CGPROGRAM
	#pragma surface surf CustomBlinnPhong
	//#pragma surface surf Lambert
	#pragma target 3.0
	ENDCG
}

FallBack "Legacy Shaders/Specular"
}
