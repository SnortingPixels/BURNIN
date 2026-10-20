// Offline test of windows/windhawk/burnin-phosphor.wh.cpp: no Windhawk, no window.
// Compiles the mod's own code, stands in for Wh_SetFunctionHook by patching d3d11's vtables, then runs Windows
// Terminal's custom-shader pass (AtlasEngine BackendD3D::_executeCustomShader) twice into an offscreen target:
// frame 1 shows picture A, frame 2 picture B. With the mod, frame 2 still carries A's fading afterglow.
//
//   test_burnin <shader.hlsl> <a.rgba> <b.rgba> <width> <height> <out.rgba> [off|windhawk]
//
// "off" skips the mod (control run). "windhawk" uses the real mod, injected by Windhawk (a test copy of the mod
// whose @include is test_burnin.exe), instead of the stand-in hooks.
#include <windows.h>
#include <d3d11.h>
#include <d3dcompiler.h>
#include <psapi.h>
#include <cstdio>
#include <vector>

static void Wh_Log(const wchar_t* fmt, ...) {
    va_list a;
    va_start(a, fmt);
    vfwprintf(stderr, fmt, a);
    va_end(a);
    fputwc(L'\n', stderr);
}

struct Hook { void* target; void* hook; };
static std::vector<Hook> g_hooks;
static BOOL Wh_SetFunctionHook(void* target, void* hook, void** orig) {
    *orig = target;   // vtable patching: the original function stays callable as is
    g_hooks.push_back({target, hook});
    return TRUE;
}
static BOOL Wh_ApplyHookOperations() { return TRUE; }

#include "../windows/windhawk/burnin-phosphor.wh.cpp"

static bool g_windhawk;

// Windhawk injects mods shortly after a process starts; wait for ours (its DLL name contains "burnin").
static bool WaitForMod() {
    for (int i = 0; i < 100; i++) {
        HMODULE mods[512];
        DWORD needed = 0;
        if (EnumProcessModules(GetCurrentProcess(), mods, sizeof(mods), &needed))
            for (DWORD j = 0; j < needed / sizeof(HMODULE) && j < 512; j++) {
                wchar_t name[MAX_PATH];
                if (GetModuleBaseNameW(GetCurrentProcess(), mods[j], name, MAX_PATH) && wcsstr(name, L"burnin")) {
                    fwprintf(stderr, L"mod loaded: %ls\n", name);
                    Sleep(500);   // let its init finish
                    return true;
                }
            }
        Sleep(100);
    }
    return false;
}

static void PatchVtable(void* obj, int count) {
    void** vt = *reinterpret_cast<void***>(obj);
    for (int i = 0; i < count; i++)
        for (auto& h : g_hooks)
            if (vt[i] == h.target) {
                DWORD old;
                VirtualProtect(&vt[i], sizeof(void*), PAGE_READWRITE, &old);
                vt[i] = h.hook;
                VirtualProtect(&vt[i], sizeof(void*), old, &old);
            }
}

static const char* kVs = R"(
struct V { float4 pos : SV_POSITION; float2 tex : TEXCOORD; };
V main(uint id : SV_VERTEXID) {
    V v;
    v.tex = float2(id & 1, id >> 1);   // same 4-vertex strip as AtlasEngine's custom_shader_vs.hlsl
    v.pos = float4(v.tex * float2(2, -2) + float2(-1, 1), 0, 1);
    return v;
})";

static std::vector<unsigned char> ReadAll(const wchar_t* path, size_t n) {
    std::vector<unsigned char> v(n);
    FILE* f = _wfopen(path, L"rb");
    if (!f || fread(v.data(), 1, n, f) != n) { fwprintf(stderr, L"cannot read %s\n", path); exit(1); }
    fclose(f);
    return v;
}

int wmain(int argc, wchar_t** argv) {
    if (argc < 7) { fprintf(stderr, "usage: test_burnin shader.hlsl a.rgba b.rgba width height out.rgba [off|windhawk]\n"); return 2; }
    bool off = argc > 7 && wcscmp(argv[7], L"off") == 0;
    g_windhawk = argc > 7 && wcscmp(argv[7], L"windhawk") == 0;
    UINT w = _wtoi(argv[4]), h = _wtoi(argv[5]);
    auto a = ReadAll(argv[2], (size_t)w * h * 4), b = ReadAll(argv[3], (size_t)w * h * 4);

    if (g_windhawk && !WaitForMod()) { fprintf(stderr, "FAIL: Windhawk did not load the mod\n"); return 1; }
    if (!off && !g_windhawk) {
        Wh_ModInit();
        if (g_hooks.size() < 3) { fprintf(stderr, "FAIL: mod set %zu hooks, expected 3\n", g_hooks.size()); return 1; }
    }

    UINT flags = D3D11_CREATE_DEVICE_SINGLETHREADED | D3D11_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS |
                 D3D11_CREATE_DEVICE_BGRA_SUPPORT;   // as AtlasEngine
    ID3D11Device* dev = nullptr; ID3D11DeviceContext* ctx = nullptr;
    if (FAILED(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, flags, nullptr, 0, D3D11_SDK_VERSION, &dev, nullptr, &ctx))) return 1;
    if (!off && !g_windhawk) {
        PatchVtable(dev, 40);
        PatchVtable(ctx, 120);
        if ((*reinterpret_cast<void***>(dev))[kCreatePsIndex] != kCreatePsHooks[0] ||
            (*reinterpret_cast<void***>(ctx))[kDrawIndex] != kDrawHooks[0]) {
            fprintf(stderr, "FAIL: hooked functions are not at ID3D11Device::CreatePixelShader / ID3D11DeviceContext::Draw\n");
            return 1;
        }
    }

    ID3DBlob *vsb = nullptr, *psb = nullptr, *err = nullptr;
    D3DCompile(kVs, strlen(kVs), "vs", nullptr, nullptr, "main", "vs_4_0", 0, 0, &vsb, &err);
    if (FAILED(D3DCompileFromFile(argv[1], nullptr, nullptr, "main", "ps_4_0", D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR, 0, &psb, &err))) {
        if (err) fprintf(stderr, "%s\n", (char*)err->GetBufferPointer());
        return 1;
    }
    ID3D11VertexShader* vs = nullptr; ID3D11PixelShader* ps = nullptr;
    dev->CreateVertexShader(vsb->GetBufferPointer(), vsb->GetBufferSize(), nullptr, &vs);
    dev->CreatePixelShader(psb->GetBufferPointer(), psb->GetBufferSize(), nullptr, &ps);
    UINT tagSize = 0;
    bool tagged = SUCCEEDED(ps->GetPrivateData(kShaderTag, &tagSize, nullptr)) && tagSize;
    fprintf(stderr, "shader tagged: %s\n", tagged ? "yes" : "no");
    if (!off && !tagged) { fprintf(stderr, "FAIL: BURNIN shader was not tagged\n"); return 1; }

    // Terminal's offscreen texture (what the shader reads at t0) and the back buffer (BGRA, like the swap chain).
    D3D11_TEXTURE2D_DESC td{};
    td.Width = w; td.Height = h; td.MipLevels = 1; td.ArraySize = 1; td.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
    td.SampleDesc.Count = 1; td.Usage = D3D11_USAGE_DEFAULT; td.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    ID3D11Texture2D* offscreen = nullptr; ID3D11ShaderResourceView* offSrv = nullptr;
    dev->CreateTexture2D(&td, nullptr, &offscreen);
    dev->CreateShaderResourceView(offscreen, nullptr, &offSrv);
    td.BindFlags = D3D11_BIND_RENDER_TARGET;
    ID3D11Texture2D* back = nullptr; ID3D11RenderTargetView* rtv = nullptr;
    dev->CreateTexture2D(&td, nullptr, &back);
    dev->CreateRenderTargetView(back, nullptr, &rtv);

    D3D11_SAMPLER_DESC sd{};
    sd.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
    sd.AddressU = sd.AddressV = sd.AddressW = D3D11_TEXTURE_ADDRESS_BORDER;
    sd.MaxLOD = D3D11_FLOAT32_MAX;
    ID3D11SamplerState* sampler = nullptr; dev->CreateSamplerState(&sd, &sampler);
    struct { float time, scale, rx, ry, bg[4]; } cbData = {2.4f, 1.0f, (float)w, (float)h, {0, 0, 0, 1}};
    D3D11_BUFFER_DESC bd{}; bd.ByteWidth = sizeof(cbData); bd.Usage = D3D11_USAGE_DEFAULT; bd.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    ID3D11Buffer* cb = nullptr; dev->CreateBuffer(&bd, nullptr, &cb);

    // RGBA files -> BGRA texture
    auto upload = [&](std::vector<unsigned char> px) {
        for (size_t i = 0; i < px.size(); i += 4) std::swap(px[i], px[i + 2]);
        ctx->UpdateSubresource(offscreen, 0, nullptr, px.data(), w * 4, 0);
    };
    auto frame = [&](float time) {
        cbData.time = time;
        ctx->UpdateSubresource(cb, 0, nullptr, &cbData, 0, 0);
        D3D11_VIEWPORT vp{0, 0, (float)w, (float)h, 0, 1};
        ctx->RSSetViewports(1, &vp);
        ctx->OMSetRenderTargets(1, &rtv, nullptr);
        ctx->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP);
        ctx->IASetInputLayout(nullptr);
        ctx->VSSetShader(vs, nullptr, 0);
        ctx->PSSetShader(ps, nullptr, 0);
        ctx->PSSetConstantBuffers(0, 1, &cb);
        ctx->PSSetShaderResources(0, 1, &offSrv);
        ctx->PSSetSamplers(0, 1, &sampler);
        ctx->OMSetBlendState(nullptr, nullptr, 0xffffffff);
        if (!off && !g_windhawk) PatchVtable(ctx, 120);   // d3d11 rewrites its (per-object) vtable as state changes
        ctx->Draw(4, 0);
        ID3D11ShaderResourceView* none = nullptr;
        ctx->PSSetShaderResources(0, 1, &none);
    };

    upload(a); frame(2.400f);
    ctx->Flush();
    Sleep(16);   // one 60 Hz frame
    upload(b); frame(2.416f);

    td.Usage = D3D11_USAGE_STAGING; td.BindFlags = 0; td.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ID3D11Texture2D* staging = nullptr; dev->CreateTexture2D(&td, nullptr, &staging);
    ctx->CopyResource(staging, back);
    D3D11_MAPPED_SUBRESOURCE map;
    if (FAILED(ctx->Map(staging, 0, D3D11_MAP_READ, 0, &map))) return 1;
    FILE* out = _wfopen(argv[6], L"wb");
    std::vector<unsigned char> row(w * 4);
    for (UINT y = 0; y < h; y++) {
        memcpy(row.data(), (unsigned char*)map.pData + (size_t)y * map.RowPitch, w * 4);
        for (UINT x = 0; x < w; x++) std::swap(row[x * 4], row[x * 4 + 2]);   // back to RGBA
        fwrite(row.data(), 1, row.size(), out);
    }
    fclose(out);
    ctx->Unmap(staging, 0);
    fprintf(stderr, "ok\n");
    return 0;
}
