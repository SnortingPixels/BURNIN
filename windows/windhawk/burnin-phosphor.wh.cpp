// ==WindhawkMod==
// @id              burnin-phosphor
// @name            BURNIN Phosphor Burn-in
// @description     Gives BURNIN's Windows Terminal shaders the previous frame, so text leaves a fading phosphor afterglow
// @version         1.0
// @author          SnortingPixels
// @github          https://github.com/SnortingPixels
// @homepage        https://github.com/SnortingPixels/BURNIN
// @include         WindowsTerminal.exe
// @architecture    x86-64
// @compilerOptions -ld3d11 -ldxguid
// ==/WindhawkMod==

// Source code is published under The GNU General Public License v3.0.

// ==WindhawkModReadme==
/*
# BURNIN Phosphor Burn-in

Real CRT phosphor keeps glowing for a moment after the beam has passed, so
text that scrolls or changes leaves a fading trail. cool-retro-term calls it
burn-in. Windows Terminal can't give a pixel shader the previous frame, so
this mod does it:

- When Windows Terminal creates a pixel shader that declares
  `BurninPrevFrame` (all BURNIN shaders do), the mod tags it.
- Each time Terminal draws with a tagged shader, the mod binds the previous
  finished frame at `t2` and the time since that frame at `b1`, then copies
  the new frame for next time.

Shaders that don't use it are left alone. After enabling the mod, switch the
BURNIN theme once (Ctrl+Alt+T) or restart Windows Terminal, so the shader is
created again and gets tagged.

Part of [BURNIN](https://github.com/SnortingPixels/BURNIN).
*/
// ==/WindhawkModReadme==

#include <windows.h>
#include <d3d11.h>
#include <string.h>
#include <vector>

// Test builds: -DRETRO_LOG_FILE=L"..." mirrors every Wh_Log line into that file.
#ifdef RETRO_LOG_FILE
#include <cstdarg>
#include <cstdio>
static void RetroLog(const wchar_t* format, ...) {
    FILE* file = _wfopen(RETRO_LOG_FILE, L"a");
    if (!file) {
        return;
    }
    SYSTEMTIME time;
    GetLocalTime(&time);
    fwprintf(file, L"%02d:%02d:%02d.%03d [%lu] ", time.wHour, time.wMinute,
             time.wSecond, time.wMilliseconds, GetCurrentThreadId());
    va_list args;
    va_start(args, format);
    vfwprintf(file, format, args);
    va_end(args);
    fputwc(L'\n', file);
    fclose(file);
}
#undef Wh_Log
#define Wh_Log(format, ...) RetroLog(format, ##__VA_ARGS__)
#endif

// Private-data keys. On a pixel shader: "this is a BURNIN shader". On Terminal's back buffer: our state for it
// (lives and dies with the back buffer, so nothing to track or free).
static const GUID kShaderTag = {0x6b1f2a4e, 0x51c3, 0x4d7a, {0x9e, 0x22, 0x0b, 0x8d, 0x3c, 0x51, 0x7e, 0x01}};
static const GUID kPrevFrame = {0x6b1f2a4e, 0x51c3, 0x4d7a, {0x9e, 0x22, 0x0b, 0x8d, 0x3c, 0x51, 0x7e, 0x02}};
static const GUID kFrameCb   = {0x6b1f2a4e, 0x51c3, 0x4d7a, {0x9e, 0x22, 0x0b, 0x8d, 0x3c, 0x51, 0x7e, 0x03}};
static const GUID kFrameTime = {0x6b1f2a4e, 0x51c3, 0x4d7a, {0x9e, 0x22, 0x0b, 0x8d, 0x3c, 0x51, 0x7e, 0x04}};

static const char kMarker[] = "BurninPrevFrame";   // resource name in the shader's reflection data

using CreatePixelShader_t = HRESULT(STDMETHODCALLTYPE*)(ID3D11Device*, const void*, SIZE_T, ID3D11ClassLinkage*, ID3D11PixelShader**);
using Draw_t = void(STDMETHODCALLTYPE*)(ID3D11DeviceContext*, UINT, UINT);
using D3D11CreateDevice_t = decltype(&D3D11CreateDevice);

// d3d11 uses different implementations (vtables) depending on device flags, so a few of each can be hooked.
constexpr int kSlots = 4;
static void* g_createPsTarget[kSlots];
static CreatePixelShader_t g_createPsOrig[kSlots];
static void* g_drawTarget[kSlots];
static Draw_t g_drawOrig[kSlots];
static D3D11CreateDevice_t g_createDeviceOrig;
static SRWLOCK g_lock = SRWLOCK_INIT;
static bool g_initDone;

static bool HasMarker(const void* code, SIZE_T len) {
    const char* p = static_cast<const char*>(code);
    const SIZE_T n = sizeof(kMarker) - 1;
    for (SIZE_T i = 0; code && i + n <= len; i++)
        if (p[i] == kMarker[0] && memcmp(p + i, kMarker, n) == 0) return true;
    return false;
}

static HRESULT CreatePixelShaderImpl(CreatePixelShader_t orig, ID3D11Device* dev, const void* code, SIZE_T len,
                                     ID3D11ClassLinkage* link, ID3D11PixelShader** out) {
    HRESULT hr = orig(dev, code, len, link, out);
    if (SUCCEEDED(hr) && out && *out && HasMarker(code, len)) {
        BYTE one = 1;
        (*out)->SetPrivateData(kShaderTag, sizeof(one), &one);
        Wh_Log(L"tagged BURNIN pixel shader %p", *out);
    }
    return hr;
}

static bool IsBurninShader(ID3D11DeviceContext* ctx) {
    ID3D11PixelShader* ps = nullptr;
    ctx->PSGetShader(&ps, nullptr, nullptr);
    if (!ps) return false;
    UINT size = 0;
    bool tagged = SUCCEEDED(ps->GetPrivateData(kShaderTag, &size, nullptr)) && size > 0;
    ps->Release();
    return tagged;
}

template <class T>
static T* GetIface(ID3D11DeviceChild* owner, REFGUID key) {
    IUnknown* unk = nullptr;
    UINT size = sizeof(unk);
    if (FAILED(owner->GetPrivateData(key, &size, &unk)) || size != sizeof(unk) || !unk) return nullptr;
    T* t = nullptr;
    unk->QueryInterface(__uuidof(T), reinterpret_cast<void**>(&t));
    unk->Release();
    return t;
}

// The previous-frame copy kept on the back buffer; recreated (zeroed: alpha 0 = "no previous frame") on resize.
static ID3D11ShaderResourceView* PrevFrame(ID3D11Device* dev, ID3D11Texture2D* backBuffer, const D3D11_TEXTURE2D_DESC& bd,
                                           ID3D11Texture2D** prevTex) {
    ID3D11ShaderResourceView* srv = GetIface<ID3D11ShaderResourceView>(backBuffer, kPrevFrame);
    if (srv) {
        ID3D11Resource* res = nullptr;
        srv->GetResource(&res);
        ID3D11Texture2D* tex = nullptr;
        if (res) { res->QueryInterface(__uuidof(ID3D11Texture2D), reinterpret_cast<void**>(&tex)); res->Release(); }
        D3D11_TEXTURE2D_DESC pd{};
        if (tex) tex->GetDesc(&pd);
        if (tex && pd.Width == bd.Width && pd.Height == bd.Height && pd.Format == bd.Format) { *prevTex = tex; return srv; }
        if (tex) tex->Release();
        srv->Release();
    }

    D3D11_TEXTURE2D_DESC d{};
    d.Width = bd.Width;
    d.Height = bd.Height;
    d.MipLevels = 1;
    d.ArraySize = 1;
    d.Format = bd.Format;
    d.SampleDesc.Count = 1;
    d.Usage = D3D11_USAGE_DEFAULT;
    d.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    std::vector<BYTE> zeros(static_cast<size_t>(bd.Width) * bd.Height * 4);   // 32-bit formats only (checked by caller)
    D3D11_SUBRESOURCE_DATA init{zeros.data(), bd.Width * 4, 0};
    ID3D11Texture2D* tex = nullptr;
    if (FAILED(dev->CreateTexture2D(&d, &init, &tex))) return nullptr;
    if (FAILED(dev->CreateShaderResourceView(tex, nullptr, &srv))) { tex->Release(); return nullptr; }
    backBuffer->SetPrivateDataInterface(kPrevFrame, srv);
    Wh_Log(L"previous-frame texture %ux%u", bd.Width, bd.Height);
    *prevTex = tex;
    return srv;
}

static ID3D11Buffer* FrameCb(ID3D11Device* dev, ID3D11Texture2D* backBuffer) {
    ID3D11Buffer* cb = GetIface<ID3D11Buffer>(backBuffer, kFrameCb);
    if (cb) return cb;
    D3D11_BUFFER_DESC d{};
    d.ByteWidth = 16;
    d.Usage = D3D11_USAGE_DEFAULT;
    d.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    if (FAILED(dev->CreateBuffer(&d, nullptr, &cb))) return nullptr;
    backBuffer->SetPrivateDataInterface(kFrameCb, cb);
    return cb;
}

// Seconds since the previous frame drawn into this back buffer; 0 on the first one (the shader then skips burn-in).
static float FrameDt(ID3D11Texture2D* backBuffer) {
    LARGE_INTEGER now, freq, last{};
    QueryPerformanceCounter(&now);
    QueryPerformanceFrequency(&freq);
    UINT size = sizeof(last);
    bool had = SUCCEEDED(backBuffer->GetPrivateData(kFrameTime, &size, &last)) && size == sizeof(last);
    backBuffer->SetPrivateData(kFrameTime, sizeof(now), &now);
    if (!had) return 0.0f;
    double dt = double(now.QuadPart - last.QuadPart) / double(freq.QuadPart);
    return dt > 0.0 ? float(dt) : 0.0f;
}

static void DrawImpl(Draw_t orig, ID3D11DeviceContext* ctx, UINT count, UINT start) {
    // Terminal's custom-shader pass is a single Draw(4, 0) of a full-window strip into the back buffer.
    if (count != 4 || start != 0) return orig(ctx, count, start);
    static bool loggedOther, loggedOurs;
    if (!IsBurninShader(ctx)) {
        if (!loggedOther) { loggedOther = true; Wh_Log(L"Draw(4, 0) with a shader that isn't tagged"); }
        return orig(ctx, count, start);
    }
    if (!loggedOurs) { loggedOurs = true; Wh_Log(L"first BURNIN draw"); }

    ID3D11RenderTargetView* rtv = nullptr;
    ctx->OMGetRenderTargets(1, &rtv, nullptr);
    ID3D11Resource* res = nullptr;
    if (rtv) { rtv->GetResource(&res); rtv->Release(); }
    ID3D11Texture2D* backBuffer = nullptr;
    if (res) { res->QueryInterface(__uuidof(ID3D11Texture2D), reinterpret_cast<void**>(&backBuffer)); res->Release(); }
    if (!backBuffer) return orig(ctx, count, start);

    D3D11_TEXTURE2D_DESC bd{};
    backBuffer->GetDesc(&bd);
    bool fourBytes = bd.Format == DXGI_FORMAT_B8G8R8A8_UNORM || bd.Format == DXGI_FORMAT_R8G8B8A8_UNORM ||
                     bd.Format == DXGI_FORMAT_R10G10B10A2_UNORM;
    if (!fourBytes || bd.SampleDesc.Count != 1 || bd.ArraySize != 1) { backBuffer->Release(); return orig(ctx, count, start); }

    ID3D11Device* dev = nullptr;
    ctx->GetDevice(&dev);
    ID3D11Texture2D* prevTex = nullptr;
    ID3D11ShaderResourceView* srv = PrevFrame(dev, backBuffer, bd, &prevTex);
    ID3D11Buffer* cb = FrameCb(dev, backBuffer);
    dev->Release();
    if (!srv || !cb) {
        if (srv) { srv->Release(); prevTex->Release(); }
        if (cb) cb->Release();
        backBuffer->Release();
        return orig(ctx, count, start);
    }

    float data[4] = {FrameDt(backBuffer), 0, 0, 0};
    ctx->UpdateSubresource(cb, 0, nullptr, data, 0, 0);

    ID3D11ShaderResourceView* oldSrv = nullptr;
    ID3D11Buffer* oldCb = nullptr;
    ctx->PSGetShaderResources(2, 1, &oldSrv);
    ctx->PSGetConstantBuffers(1, 1, &oldCb);
    ctx->PSSetShaderResources(2, 1, &srv);
    ctx->PSSetConstantBuffers(1, 1, &cb);

    orig(ctx, count, start);

    // Unbind before copying into the texture, then put back whatever was there.
    ctx->PSSetShaderResources(2, 1, &oldSrv);
    ctx->PSSetConstantBuffers(1, 1, &oldCb);
    ctx->CopyResource(prevTex, backBuffer);

    if (oldSrv) oldSrv->Release();
    if (oldCb) oldCb->Release();
    cb->Release();
    srv->Release();
    prevTex->Release();
    backBuffer->Release();
}

template <int N>
static HRESULT STDMETHODCALLTYPE CreatePixelShaderHook(ID3D11Device* dev, const void* code, SIZE_T len,
                                                       ID3D11ClassLinkage* link, ID3D11PixelShader** out) {
    return CreatePixelShaderImpl(g_createPsOrig[N], dev, code, len, link, out);
}

template <int N>
static void STDMETHODCALLTYPE DrawHook(ID3D11DeviceContext* ctx, UINT count, UINT start) {
    DrawImpl(g_drawOrig[N], ctx, count, start);
}

static void* const kCreatePsHooks[kSlots] = {(void*)CreatePixelShaderHook<0>, (void*)CreatePixelShaderHook<1>,
                                             (void*)CreatePixelShaderHook<2>, (void*)CreatePixelShaderHook<3>};
static void* const kDrawHooks[kSlots] = {(void*)DrawHook<0>, (void*)DrawHook<1>, (void*)DrawHook<2>, (void*)DrawHook<3>};

// vtable slots: ID3D11Device::CreatePixelShader, ID3D11DeviceContext::Draw
constexpr int kCreatePsIndex = 15;
constexpr int kDrawIndex = 13;

static bool HookSlot(void* target, void** targets, void* const* hooks, void** origs) {
    for (int i = 0; i < kSlots; i++) {
        if (targets[i] == target) return false;
        if (!targets[i]) {
            targets[i] = target;
            return Wh_SetFunctionHook(target, hooks[i], &origs[i]);
        }
    }
    Wh_Log(L"no free hook slot");
    return false;
}

// Hooks this device's CreatePixelShader and its context's Draw, if those implementations aren't hooked yet.
static void HookDevice(ID3D11Device* dev, ID3D11DeviceContext* ctx) {
    if (!dev || !ctx) return;
    void* createPs = (*reinterpret_cast<void***>(dev))[kCreatePsIndex];
    void* draw = (*reinterpret_cast<void***>(ctx))[kDrawIndex];
    AcquireSRWLockExclusive(&g_lock);
    bool added = HookSlot(createPs, g_createPsTarget, kCreatePsHooks, reinterpret_cast<void**>(g_createPsOrig));
    added |= HookSlot(draw, g_drawTarget, kDrawHooks, reinterpret_cast<void**>(g_drawOrig));
    ReleaseSRWLockExclusive(&g_lock);
    if (added) {
        Wh_Log(L"hooked CreatePixelShader %p, Draw %p", createPs, draw);
        if (g_initDone) Wh_ApplyHookOperations();
    }
}

static HRESULT WINAPI D3D11CreateDeviceHook(IDXGIAdapter* adapter, D3D_DRIVER_TYPE type, HMODULE sw, UINT flags,
                                            const D3D_FEATURE_LEVEL* levels, UINT nLevels, UINT sdk, ID3D11Device** dev,
                                            D3D_FEATURE_LEVEL* level, ID3D11DeviceContext** ctx) {
    HRESULT hr = g_createDeviceOrig(adapter, type, sw, flags, levels, nLevels, sdk, dev, level, ctx);
    if (SUCCEEDED(hr) && dev && *dev && ctx && *ctx) HookDevice(*dev, *ctx);
    return hr;
}

// A throwaway device with Windows Terminal's flags, to find the implementations its devices use.
static void HookLikeTerminal(UINT flags) {
    ID3D11Device* dev = nullptr;
    ID3D11DeviceContext* ctx = nullptr;
    if (SUCCEEDED(g_createDeviceOrig ? g_createDeviceOrig(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, flags, nullptr, 0,
                                                          D3D11_SDK_VERSION, &dev, nullptr, &ctx)
                                     : D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, flags, nullptr, 0,
                                                         D3D11_SDK_VERSION, &dev, nullptr, &ctx))) {
        HookDevice(dev, ctx);
        ctx->Release();
        dev->Release();
    }
}

BOOL Wh_ModInit() {
    Wh_Log(L"init");
    HMODULE d3d11 = LoadLibraryW(L"d3d11.dll");
    void* createDevice = d3d11 ? (void*)GetProcAddress(d3d11, "D3D11CreateDevice") : nullptr;
    if (createDevice) Wh_SetFunctionHook(createDevice, (void*)D3D11CreateDeviceHook, (void**)&g_createDeviceOrig);

    // AtlasEngine: SINGLETHREADED | PREVENT_INTERNAL_THREADING_OPTIMIZATIONS | BGRA_SUPPORT (see AtlasEngine.r.cpp)
    HookLikeTerminal(D3D11_CREATE_DEVICE_SINGLETHREADED | D3D11_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS |
                     D3D11_CREATE_DEVICE_BGRA_SUPPORT);
    g_initDone = true;
    return TRUE;
}

void Wh_ModUninit() {
    Wh_Log(L"uninit");
}
