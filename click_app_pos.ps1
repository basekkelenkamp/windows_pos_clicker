# Set variables
$applicationPath = "C:\WINDOWS\system32\mspaint.exe"
$windowTitle = "Untitled - Paint"

# Define your click positions as x, y offsets from the top-left corner of the window
$clickPositions = @( @{ X = 268; Y = 68 }, @{ X = 853; Y = 62 } , @{ X = 465; Y = 368 } )

# Define the Click-At function
function Click-At {
    param(
        [int]$x,
        [int]$y
    )

    [Clicker]::LeftClickAtPoint($x, $y)
}

# Add necessary class and structures
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class User32 {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetCursorPos(int X, int Y);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [StructLayout(LayoutKind.Sequential)]
        public struct RECT {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct POINT {
            public int X;
            public int Y;
        }
    }
"@

# Add the Clicker class to the script
$cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class Clicker
{
    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    { 
        public int        type; // 0 = INPUT_MOUSE
                                // 1 = INPUT_KEYBOARD
                                // 2 = INPUT_HARDWARE
        public MOUSEINPUT mi;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct MOUSEINPUT
    {
        public int    dx;
        public int    dy;
        public int    mouseData;
        public int    dwFlags;
        public int    time;
        public IntPtr dwExtraInfo;
    }

    const int MOUSEEVENTF_MOVE       = 0x0001;
    const int MOUSEEVENTF_LEFTDOWN   = 0x0002;
    const int MOUSEEVENTF_LEFTUP     = 0x0004;
    const int MOUSEEVENTF_RIGHTDOWN  = 0x0008;
    const int MOUSEEVENTF_RIGHTUP    = 0x0010;
    const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
    const int MOUSEEVENTF_MIDDLEUP   = 0x0040;
    const int MOUSEEVENTF_WHEEL      = 0x0080;
    const int MOUSEEVENTF_XDOWN      = 0x0100;
    const int MOUSEEVENTF_XUP        = 0x0200;
    const int MOUSEEVENTF_ABSOLUTE   = 0x8000;

    const int screen_length = 0x10000;

    [System.Runtime.InteropServices.DllImport("user32.dll")]
    extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    public static void LeftClickAtPoint(int x, int y)
    {
        INPUT[] input = new INPUT[3];

        input[0].mi.dx = x * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
        input[0].mi.dy = y * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
        input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;

        // Left mouse button down
        input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;

        // Left mouse button up
        input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;

        SendInput(3, input, Marshal.SizeOf(input[0]));
    }
}
'@

Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing

# Start the application
Start-Process $applicationPath

# Wait for a few seconds to ensure the application window is ready
Start-Sleep -Seconds 5

# Find the application window
$hWnd = [User32]::FindWindow([NullString]::Value, $windowTitle)

if ($hWnd -eq [IntPtr]::Zero) {
    Write-Host "Could not find window with title '$windowTitle'"
    exit 1
}

# Bring the application window to the foreground
[User32]::SetForegroundWindow($hWnd)

# Maximize the application window
[User32]::ShowWindow($hWnd, 3)

# Get the application window position
$rect = New-Object User32.RECT
[User32]::GetWindowRect($hWnd, [ref]$rect)


# Click with a delay
foreach ($position in $clickPositions) {
    $x = $rect.Left + $position.X
    $y = $rect.Top + $position.Y
    Write-Host "Clicking at position X: $x, Y: $y"
    Click-At -x $x -y $y
    Start-Sleep -Seconds 2 # Wait a bit before the next click
}
Write-Host "Clicks completed."
