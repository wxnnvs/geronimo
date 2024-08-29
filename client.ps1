# Client Script: client.ps1

$server = "127.0.0.1"  # Server IP
$port = 8888           # Port to connect to

$firstconnect = $true

# Some necessary shit
function Read-Host($prompt) {
    Write-Host "$prompt  " -NoNewline
    Microsoft.PowerShell.Utility\Read-Host 
}

function Send-Command($command) {
    $writer.WriteLine($command)

    $result = $reader.ReadToEnd()
    Write-Host $result
}

while ($true) {

    try {
        # Connect to the server
        $client = [System.Net.Sockets.TcpClient]::new($server, $port)
        $stream = $client.GetStream()
        if ($firstconnect) {
            $firstconnect = $false
            Write-Host "Connected to server at $($server):$($port)"
        }
        
        # Prompt user for command
        $command = Read-Host "PS $($server)>"

        # Send the command to the server
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        # Receive the result from the server
        $reader = New-Object System.IO.StreamReader($stream)

        # clear client terminal
        if ($command -eq "clear") {
            Clear-Host
        } 

        elseif ($command.StartsWith("exit")) {
            $params = $command.Split(" ")
            if ($params[1] -eq "-s") {
                $writer.WriteLine("exit")
                break
            }
            else {
                break
            }
        }
        
        else {
            Send-Command $command
        }

        # Clean up
        $writer.Close()
        $reader.Close()
        $stream.Close()
        $client.Close()

    } catch {
        Write-Host "Error: $_"
    }
 }