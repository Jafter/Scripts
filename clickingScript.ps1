<# The Auto-Clicker
   
   Repurposed from: http://www.daveamenta.com/2013-08/use-powershell-to-automatically-click-a-point-on-the-screen-reapeatedly-auto-clicker/
   Modified by:     Wolf
   Requirements: Windows 8 or higher
   
   I repurposed this code in order to facilitate the tedious clicking that must be done every 30 or so
   seconds on the Hero.TV webcast service. 

   Point your mouse cursor onto the area you wish to click multiple times over, and have Windows Powershell 
   open and directed at the location of this script.

   To run the command, simply write:
   .\clickingScript.ps1

   **MAKE SURE YOU HAVE YOUR CURSOR AT THE RIGHT LOCATION**

   The command should look like this:
   PS C:\Users\Wolf\Desktop> .\clickingScript.ps1
   
   **MAKE SURE YOU RUN THE SCRIPT FROM ITS PROPER LOCATION**

   NOTE: This script assumes you are using the Hero.TV webcast service to auto-click emotes. The script starts 
   a loop; it'll click at the desired location extremely quickly and then wait 30 seconds for the emote bubble 
   to refill. In this wait time, you may do anything you'd like, however you must ensure that the emote button 
   is visible on screen, or return to the cast before the timer resets, as this script will return the mouse 
   pointer at the originally chosen location. The time intervals are not optimized, but it works well non the 
   less. If you feel the need to optimize them, have fun!

 #>

[CmdletBinding()]
param($Interval = 10, [switch]$RightClick, [switch]$NoMove) <# Change the Interval value here for click speed, value is in ms #>

[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
$DebugViewWindow_TypeDef = @'
[DllImport("user32.dll")]
public static extern IntPtr FindWindow(string ClassName, string Title);
[DllImport("user32.dll")]
public static extern IntPtr GetForegroundWindow();
[DllImport("user32.dll")]
public static extern bool SetCursorPos(int X, int Y);
[DllImport("user32.dll")]
public static extern bool GetCursorPos(out System.Drawing.Point pt);
 
[DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
 
private const int MOUSEEVENTF_LEFTDOWN = 0x02;
private const int MOUSEEVENTF_LEFTUP = 0x04;
private const int MOUSEEVENTF_RIGHTDOWN = 0x08;
private const int MOUSEEVENTF_RIGHTUP = 0x10;
 
public static void LeftClick(){
    mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
}
 
public static void RightClick(){
    mouse_event(MOUSEEVENTF_RIGHTDOWN | MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
}
'@
Add-Type -MemberDefinition $DebugViewWindow_TypeDef -Namespace AutoClicker -Name Temp -ReferencedAssemblies System.Drawing

$timer = 0  
$pt = New-Object System.Drawing.Point
if ([AutoClicker.Temp]::GetCursorPos([ref]$pt)) {
    Write-host "Clicking at $($pt.X), $($pt.Y) every ${Interval}ms until Ctrl^C or " -NoNewline
    Write-Host -ForegroundColor Cyan "Start " -NoNewline
    Write-Host "is open."
    while($true) {
        $start = [AutoClicker.Temp]::FindWindow("ImmersiveLauncher", "Start menu")
        $fg = [AutoClicker.Temp]::GetForegroundWindow()
 
        if ($start -eq $fg) { 
            Write-Host "Start opened. Exiting"
            return 
        }

        if (!$NoMove) {
            [AutoClicker.Temp]::SetCursorPos($pt.X, $pt.Y) | Out-Null
        }
 
        if ($RightClick) {
            [AutoClicker.Temp]::RightClick()
        } else {
            [AutoClicker.Temp]::LeftClick()
        }

        $timer++

        if ($timer -eq 200) {
            $timer = 0
            Write-Host "Filled up likes... Waiting."
            sleep -s 30 <# Change the sleep time if you'd like to wait longer between clicks #>
            Write-Host "Waiting Done, resuming likes."
        }

        sleep -Milliseconds $Interval
    }
}