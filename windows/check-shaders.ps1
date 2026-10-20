# Compiles HLSL pixel shaders the way Windows Terminal does (ps_4_0, entry "main").
# Usage: check-shaders.ps1 <file.hlsl> [more.hlsl ...]   Exit code 1 if any fail.
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Paths)
if (-not ('WtShaderCheck' -as [type])) {
  Add-Type -TypeDefinition @'
using System; using System.Runtime.InteropServices;
public static class WtShaderCheck {
  [DllImport("d3dcompiler_47.dll", CharSet=CharSet.Ansi)]
  static extern int D3DCompileFromFile([MarshalAs(UnmanagedType.LPWStr)] string file, IntPtr defs, IntPtr inc, string entry, string target, uint f1, uint f2, out IntPtr code, out IntPtr err);
  [ComImport, Guid("8BA5FB08-5195-40e2-AC58-0D989C3A0102"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
  interface IBlob { [PreserveSig] IntPtr GetBufferPointer(); [PreserveSig] IntPtr GetBufferSize(); }
  public static string Run(string f, out bool ok) {
    IntPtr c, e; int hr = D3DCompileFromFile(f, IntPtr.Zero, IntPtr.Zero, "main", "ps_4_0", 0, 0, out c, out e);
    string msg = "";
    if (e != IntPtr.Zero) { var b = (IBlob)Marshal.GetObjectForIUnknown(e); msg = Marshal.PtrToStringAnsi(b.GetBufferPointer()); }
    ok = hr == 0;
    return (ok ? "ok" : "FAIL 0x" + hr.ToString("X8")) + (msg.Trim().Length > 0 ? " " + msg.Trim() : "");
  }
}
'@
}
$bad = 0
foreach ($p in $Paths) {
  $ok = $false
  $r = [WtShaderCheck]::Run((Resolve-Path $p).Path, [ref]$ok)
  if (-not $ok) { $bad++ }
  '{0,-28} {1}' -f (Split-Path $p -Leaf), $r
}
if ($bad) { exit 1 }
