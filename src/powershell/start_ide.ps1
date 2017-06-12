Param(
  [Parameter(Mandatory)]
  [String]$NAVIDE,
  [Parameter(Mandatory)]
  [String]$DatabaseName
)

if(-not (Test-Path $NAVIde)) {
  throw "NAV IDE not found. '$NAVIde'"
}

Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Tricks {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
  }
"@ -Debug:$false

$process = Get-Process | Where-Object {$PSItem.Path -eq $NAVIDE}
if($process) {
 [void] [Tricks]::ShowWindowAsync($process.MainWindowHandle, 2)
 [void] [Tricks]::ShowWindowAsync($process.MainWindowHandle, 10)
 return
}

$Arguments = "servername={0}, database={1}, ntauthentication=1" -f $env:computername,$DatabaseName
Start-Process -FilePath $NAVIde -ArgumentList $Arguments