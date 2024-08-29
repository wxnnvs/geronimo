# Server Script: server.ps1

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

$listener.Stop()
