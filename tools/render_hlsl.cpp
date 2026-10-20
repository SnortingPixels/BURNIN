// Renders a Windows Terminal pixel shader offline, the way Windows Terminal runs it: the shader's input is the
// terminal picture (texture t0, linear sampler s0) and its constant buffer {Time, Scale, Resolution, Background}.
// No window: renders into a texture and writes the result. Used by tools/screenshots.py for the README images.
//
//   render_hlsl <shader.hlsl> <in.rgba> <width> <height> <time> <out.rgba>
//
// in/out are raw 8-bit RGBA, top row first.
#include <windows.h>
#include <d3d11.h>
#include <d3dcompiler.h>
#include <cstdio>
#include <vector>

static const char* kVertexShader = R"(
struct V { float4 pos : SV_POSITION; float2 tex : TEXCOORD; };
V main(uint id : SV_VertexID) {
    V v;
    v.tex = float2((id << 1) & 2, id & 2);               // fullscreen triangle
    v.pos = float4(v.tex * float2(2, -2) + float2(-1, 1), 0, 1);
    return v;
})";

struct Constants { float time, scale, resX, resY, bg[4]; };

static bool fail(const char* what, HRESULT hr) { fprintf(stderr, "%s failed: 0x%08lX\n", what, (unsigned long)hr); return false; }

int wmain(int argc, wchar_t** argv) {
    if (argc != 7) { fprintf(stderr, "usage: render_hlsl shader.hlsl in.rgba width height time out.rgba\n"); return 2; }
    const wchar_t* shaderPath = argv[1];
    UINT w = _wtoi(argv[3]), h = _wtoi(argv[4]);
    float time = (float)_wtof(argv[5]);

    std::vector<unsigned char> pixels((size_t)w * h * 4);
    FILE* in = _wfopen(argv[2], L"rb");
    if (!in || fread(pixels.data(), 1, pixels.size(), in) != pixels.size()) { fprintf(stderr, "cannot read input\n"); return 1; }
    fclose(in);

    ID3D11Device* dev = nullptr; ID3D11DeviceContext* ctx = nullptr;
    HRESULT hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx);
    if (FAILED(hr)) hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr, 0, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx);
    if (FAILED(hr)) return !fail("D3D11CreateDevice", hr);

    ID3DBlob *vsBlob = nullptr, *psBlob = nullptr, *err = nullptr;
    hr = D3DCompile(kVertexShader, strlen(kVertexShader), "vs", nullptr, nullptr, "main", "vs_4_0", 0, 0, &vsBlob, &err);
    if (FAILED(hr)) { if (err) fprintf(stderr, "%s\n", (char*)err->GetBufferPointer()); return 1; }
    hr = D3DCompileFromFile(shaderPath, nullptr, nullptr, "main", "ps_4_0", 0, 0, &psBlob, &err);
    if (FAILED(hr)) { if (err) fprintf(stderr, "%s\n", (char*)err->GetBufferPointer()); return 1; }
    ID3D11VertexShader* vs = nullptr; ID3D11PixelShader* ps = nullptr;
    dev->CreateVertexShader(vsBlob->GetBufferPointer(), vsBlob->GetBufferSize(), nullptr, &vs);
    dev->CreatePixelShader(psBlob->GetBufferPointer(), psBlob->GetBufferSize(), nullptr, &ps);

    D3D11_TEXTURE2D_DESC td = {};
    td.Width = w; td.Height = h; td.MipLevels = 1; td.ArraySize = 1; td.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    td.SampleDesc.Count = 1; td.Usage = D3D11_USAGE_DEFAULT; td.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    D3D11_SUBRESOURCE_DATA init = { pixels.data(), w * 4, 0 };
    ID3D11Texture2D* src = nullptr; ID3D11ShaderResourceView* srv = nullptr;
    if (FAILED(hr = dev->CreateTexture2D(&td, &init, &src))) return !fail("CreateTexture2D(src)", hr);
    dev->CreateShaderResourceView(src, nullptr, &srv);

    td.BindFlags = D3D11_BIND_RENDER_TARGET;
    ID3D11Texture2D* target = nullptr; ID3D11RenderTargetView* rtv = nullptr;
    if (FAILED(hr = dev->CreateTexture2D(&td, nullptr, &target))) return !fail("CreateTexture2D(target)", hr);
    dev->CreateRenderTargetView(target, nullptr, &rtv);

    D3D11_SAMPLER_DESC sd = {};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ID3D11SamplerState* sampler = nullptr; dev->CreateSamplerState(&sd, &sampler);

    Constants c = { time, 1.0f, (float)w, (float)h, { 0, 0, 0, 1 } };
    D3D11_BUFFER_DESC bd = {}; bd.ByteWidth = sizeof(c); bd.Usage = D3D11_USAGE_DEFAULT; bd.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    D3D11_SUBRESOURCE_DATA cinit = { &c, 0, 0 };
    ID3D11Buffer* cb = nullptr; dev->CreateBuffer(&bd, &cinit, &cb);

    D3D11_VIEWPORT vp = { 0, 0, (float)w, (float)h, 0, 1 };
    ctx->RSSetViewports(1, &vp);
    ctx->OMSetRenderTargets(1, &rtv, nullptr);
    ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    ctx->VSSetShader(vs, nullptr, 0);
    ctx->PSSetShader(ps, nullptr, 0);
    ctx->PSSetShaderResources(0, 1, &srv);
    ctx->PSSetSamplers(0, 1, &sampler);
    ctx->PSSetConstantBuffers(0, 1, &cb);
    ctx->Draw(3, 0);

    td.Usage = D3D11_USAGE_STAGING; td.BindFlags = 0; td.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ID3D11Texture2D* staging = nullptr; dev->CreateTexture2D(&td, nullptr, &staging);
    ctx->CopyResource(staging, target);
    D3D11_MAPPED_SUBRESOURCE map;
    if (FAILED(hr = ctx->Map(staging, 0, D3D11_MAP_READ, 0, &map))) return !fail("Map", hr);
    FILE* out = _wfopen(argv[6], L"wb");
    for (UINT y = 0; y < h; y++) fwrite((unsigned char*)map.pData + (size_t)y * map.RowPitch, 1, (size_t)w * 4, out);
    fclose(out);
    ctx->Unmap(staging, 0);
    return 0;
}
