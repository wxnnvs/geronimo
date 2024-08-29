# Geronimo
A Remote Administration Tool written in powershell.

> [!WARNING]
> Geronimo is in its early testing stages, some features may not work as intended.

## Features
- [x] CLI-access
- [ ] Elevated command execution
- [ ] Upload files to client
- [ ] Download files from client
- [ ] Autostart on boot
- [ ] Hidden from Taskmanager

## Installation
1. Clone this project

2. In **server.ps1**, specify the port to listen on.
3. Run **server.ps1** on the target machine.

4. In **client.ps1**, specify the target's IP and port.
5. Run **client.ps1** on the attacking machine.
6. **Profit!**

## Commands
```
- clear      -->  clear your screen
- exit [-s]  -->  shutdown the client [and the server]
```
> [!NOTE]
> All other commands will be executed as a Powershell command.

*Geronimo is provided as an administration tool to be used inside your personal network. I (wxnnvs) cannot be held liable for any misuse of this tool. All responsibility is at the users end.*