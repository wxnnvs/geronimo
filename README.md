# reverse-powershell

A very minimal Powershell-based reverse shell.

## Features
- [x] Command-line access
- [x] Upload/download files to/from client
- [x] Autostart on boot
- [x] Hidden from Taskmanager

## Usage
1. Clone this project

2. In **server.ps1**, specify the IP and port to listen on
3. Run server.ps1 on the attacking machine

4. In **client.ps1**, specify the attacker's IP and port and the name of the shortcut.
5. Run client.ps1 on the target machine
6. **Profit!**
