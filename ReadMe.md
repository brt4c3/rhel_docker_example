# How to start using Jenkins 

- open terminal with admin priviledge [win] + [r] 
- type "powershell" and then [ctrl] + [shift] + [enter]
- run the `jenkins/install_fedora_jenkins.bat` to install JEnkins and Podman and Ansible automatically to WSL
- start jenkins `wsl -d FedoraLinux-42 -u fedora -- sudo systemctl start jenkins` 
- and then read the log `wsl -d FedoraLinux-42 -u fedora -- sudo journalctl -u jenkins -f`
- create pipeline yourself by copy and paste the `Jenkinsfile`


install Qemu
- https://qemu.weilnetz.de/w64/2025/