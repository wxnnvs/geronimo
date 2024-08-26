# Geronimo
A Remote Administration Tool written in powershell.

> [!WARNING]
> Geronimo is in its early testing stages, some features may not work as intended.

## Features
- [x] CLI-access
- [x] Elevated command execution
- [x] Upload files to client
- [x] Download files from client
- [x] Autostart on boot
- [x] Hidden from Taskmanager

## Usage
1. Clone this project

2. In **server.ps1**, specify the IP and port to listen on
3. Run server.ps1 on the attacking machine

4. In **client.ps1**, specify the attacker's IP and port and the name of the shortcut.
5. Run client.ps1 on the target machine
6. **Profit!**

*Geronimo is provided as an administration tool to be used inside your personal network. I (wxnnvs) cannot be held liable for any misuse of this tool. All responsibility is at the users end.*