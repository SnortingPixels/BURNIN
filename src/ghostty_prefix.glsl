#version 430 core
// Test harness only: approximates the prefix Ghostty adds to custom shaders (Shadertoy uniforms),
// so src/check_glsl.py can compile dist/ghostty/*.glsl with glslang the way Ghostty does.
layout(binding = 1, std140) uniform Globals {
    uniform vec3 iResolution;
    uniform float iTime;
    uniform float iTimeDelta;
    uniform float iFrameRate;
    uniform int iFrame;
    uniform float iChannelTime[4];
    uniform vec3 iChannelResolution[4];
    uniform vec4 iMouse;
    uniform vec4 iDate;
    uniform float iSampleRate;
    uniform vec4 iCurrentCursor;
    uniform vec4 iPreviousCursor;
    uniform vec4 iCurrentCursorColor;
    uniform vec4 iPreviousCursorColor;
    uniform int iCurrentCursorStyle;
    uniform int iPreviousCursorStyle;
    uniform int iCursorVisible;
    uniform float iTimeCursorChange;
};
layout(binding = 0) uniform sampler2D iChannel0;
layout(location = 0) out vec4 _fragColor;
void mainImage(out vec4 fragColor, in vec2 fragCoord);
void main() { mainImage(_fragColor, gl_FragCoord.xy); }
#line 1
