@echo off
echo ================================================
echo Setting up Fedora WSL and Jenkins installation...
echo ================================================

:: Set CD to the script's directory
set "CD=%~dp0"
echo Script directory set to: %CD%

:: Check for admin privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges. Please run as Administrator.
    pause
    exit /b 1
)

:: Check system code page
echo Checking system code page...
for /f "tokens=2 delims=:" %%i in ('chcp') do set "CODEPAGE=%%i"
set "CODEPAGE=%CODEPAGE: =%"
set "CODEPAGE=%CODEPAGE:.=%"
echo Raw CODEPAGE value: [%CODEPAGE%]
if not "%CODEPAGE%"=="65001" (
    echo ERROR: Code page is not UTF-8 65001. This script requires UTF-8 to properly process WSL output.
    echo Please set the code page to UTF-8 by running 'chcp 65001' in Command Prompt and try again.
    pause
    exit /b 1
)
echo Current code page: %CODEPAGE% (UTF-8)

:: Check if WSL is installed
wsl --list >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WSL is not installed. Enabling WSL and installing Fedora...
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    echo Installing WSL with Fedora distribution...
    wsl --install FedoraLinux-42 || (
        echo Failed to install FedoraLinux-42. Please provide a Fedora tarball and use wsl --import.
        pause
        exit /b 1
    )
    echo Enter UNIX username as 'fedora' and then [Ctrl]+[D] to exit
    pause
)

:: Update WSL to the latest version
echo Updating WSL...
wsl --update

:: Check if FedoraLinux-42 is installed
echo Checking for FedoraLinux-42...
wsl --list --all > wsl_distros.txt
type wsl_distros.txt
powershell -Command "Get-Content wsl_distros.txt | Select-String 'FedoraLinux' | Out-Null; exit $LASTEXITCODE"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: FedoraLinux-42 not found. Check wsl_distros.txt for issues.
    echo Run 'certutil -encodehex wsl_distros.txt wsl_distros_hex.txt' to inspect encoding.
    pause
    exit /b 1
) else (
    echo FedoraLinux-42 is installed.
)

:: Create fedora user if not exists
echo Ensuring 'fedora' user exists...
wsl -d FedoraLinux-42 -u root bash -c "id fedora >/dev/null 2>&1 || (useradd -m -G wheel fedora && echo 'User created: fedora')"

:: Clean up
del wsl_distros.txt 2>nul

:: Install Git
echo Installing Git inside FedoraLinux-42...
wsl -d FedoraLinux-42 -u fedora -- sudo dnf install -y git

:: Clone Jenkins example repo
echo Cloning Jenkins Docker example repo...
wsl -d FedoraLinux-42 -u fedora -- rm -rf rhel_docker_example >/dev/null 2>&1
wsl -d FedoraLinux-42 -u fedora -- git clone https://github.com/brt4c3/rhel_docker_example.git

:: Check if Jenkins install script exists
echo Verifying Jenkins install script...
wsl -d FedoraLinux-42 -u fedora bash -c "[ -f rhel_docker_example/jenkins/install_jenkins.sh ] || (echo 'ERROR: install_jenkins.sh not found' && exit 1)"
if %ERRORLEVEL% NEQ 0 (
    echo Jenkins installation script not found. Ensure the repository cloned correctly.
    pause
    exit /b 1
)

:: Optional: Set executable permissions
echo Setting script as executable...
wsl -d FedoraLinux-42 -u fedora -- chmod +x rhel_docker_example/jenkins/install_jenkins.sh

:: Check if port 8080 is already in use
netstat -aon | findstr :8080 >nul
if %ERRORLEVEL% EQU 0 (
    echo WARNING: Port 8080 is already in use. Jenkins may not be accessible. Consider freeing the port.
    pause
)

:: Port forwarding setup
echo Configuring Windows port forwarding to WSL2...
powershell -Command "netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0" >nul 2>&1
powershell -Command "netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=8080 connectaddress=127.0.0.1"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to set up port forwarding. Jenkins may not be reachable from Windows.
    pause
    exit /b 1
)

:: Run Jenkins installation script with output logging
echo Running Jenkins install script in Fedora WSL...
wsl -d FedoraLinux-42 -u fedora -- bash -c "cd rhel_docker_example/jenkins && /bin/bash -x install_jenkins.sh 2>&1 | tee jenkins_install.log"
if %ERRORLEVEL% NEQ 0 (
    echo Jenkins installation failed. Check log inside WSL: ~/rhel_docker_example/jenkins/jenkins_install.log
    pause
    exit /b 1
)

:: Optional: Terminate WSL to refresh state
echo Terminating FedoraLinux-42 to apply changes...
wsl --terminate FedoraLinux-42

:: Final success message
echo ============================================
echo Jenkins setup complete!
echo Access Jenkins in your browser at:
echo      http://localhost:8080
echo
echo To check the initial admin password:
echo      wsl -d FedoraLinux-42 -u fedora cat /var/lib/jenkins/secrets/initialAdminPassword
echo
echo To check Jenkins status:
echo      wsl -d FedoraLinux-42 -u fedora systemctl status jenkins
echo (Note: If systemd is not enabled, Jenkins may not auto-start.)
echo ============================================
pause
