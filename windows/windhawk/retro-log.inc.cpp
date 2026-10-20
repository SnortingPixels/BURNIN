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
