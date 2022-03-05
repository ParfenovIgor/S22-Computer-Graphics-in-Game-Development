#define LIGHT_NUM 1
struct Light
{
	float4 position;
	float4 color;
};

cbuffer ConstantBuffer : register(b0)
{
	float4x4 mwpMatrix;
	Light light;
};

Texture2D g_texture : register(t0);
SamplerState g_sampler : register(s0);

struct PSInput
{
	float4 position : SV_POSITION;
	float4 color : COLOR;
	float2 uv : TEXCOORD;
	float3 world_pos : POSITION;
	float3 normal : NORMAL;
};

PSInput VSMain(float4 position : POSITION, float4 normal: NORMAL, float4 ambient : COLOR0, float4 diffuse : COLOR1,  float4 emissive : COLOR2, float4 texcoords : TEXCOORD)
{
	PSInput result;


	result.position = mul(mwpMatrix, position);
	result.color = diffuse;
	result.uv = texcoords.xy;
	result.world_pos = position.xyz;
	result.normal = normal.xyz;

	return result;
}

float GetLambertianIntensity(PSInput input, float4 light_position, float4 light_color)
{
	float3 to_light = light_position.xyz - input.world_pos;
	float distance = length(to_light);
	float attenuation = 1.f / (distance * distance + 1.f);
	return saturate(dot(input.normal, to_light)) * attenuation * light_color;
}

float4 PSMain(PSInput input) : SV_TARGET
{
	return input.color * GetLambertianIntensity(input, light.position, light.color);
}

float4 PSMain_texture(PSInput input) : SV_TARGET
{
	return g_texture.Sample(g_sampler, input.uv) * GetLambertianIntensity(input, light.position, light.color);
}