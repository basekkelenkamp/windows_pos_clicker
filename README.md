# windows_pos_clicker
Script to automate opening an app and do some position clicks in it.

Set variables:
- $applicationPath
- $windowTitle

Define  click positions as x, y offsets from the top-left corner of the window:
- $clickPositions = @( @{ X = 268; Y = 68 }, @{ X = 853; Y = 62 } , @{ X = 465; Y = 368 } )

## Get the mouse pos
Run in powershell to get mouse positions:
```
Add-Type -AssemblyName System.Windows.Forms
 
$X = [System.Windows.Forms.Cursor]::Position.X
$Y = [System.Windows.Forms.Cursor]::Position.Y
 
Write-Output "X: $X | Y: $Y"
```
