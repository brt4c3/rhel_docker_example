# How to start using Jenkins 

- open terminal with admin priviledge [win] + [r] 
- type "powershell" and then [ctrl] + [shift] + [enter]
- run the `jenkins/install_fedora_jenkins.bat` to install JEnkins and Podman and Ansible automatically to WSL
- start jenkins `wsl -d FedoraLinux-42 -u fedora -- sudo systemctl start jenkins` 
- and then read the log `wsl -d FedoraLinux-42 -u fedora -- sudo journalctl -u jenkins -f`
- create pipeline yourself by copy and paste the `Jenkinsfile`


# 準備する資材のディレクトリ構成
```
C:\IBM\MW
+---IIM
|   |   agent.installer.linux.gtk.x86_64_1.9.2008.20240227_0018.zip
|   |
|   \---configuration
|       |   config.ini
|       |   config.ini.backup
|       |
|       \---org.eclipse.update
|               platform.xml
|
\---WAS
        wlp-webProfile8-java8-linux-x86_64-24.0.0.6.zip
```

# インストール時にIHSの警告文を迂回するためのコンフィグファイル
/opt/IBM/InstallationManager/eclipse/configuration/config.ini

## IHSは手動でInstallation Managerを使用しインストール
docker exec -it [コンテナ名] /bin/bash
 /opt/IBM/InstallationManager/eclipse/IBMIM
 Linux では、/opt/IBM/InstallationManager/eclipse/IBMIM コマンドを実行
 Installation Manager で、「ファイル」 > 「設定」 > 「リポジトリー」をクリック
「リポジトリーの追加」をクリックし、次の URL を入力
 https://www.ibm.com/software/repositorymanager/V85WASIHSILAN
 サポート→　https://www.ibm.com/docs/ja/api-connect/5.0.x?topic=connect-installing-http-server
