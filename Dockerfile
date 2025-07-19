FROM redhat/ubi9

# ISO FileCopy
RUN mkdir /iso
COPY /iso/rhel-9.4-x86_64-boot.iso /iso/

# unzipコマンドをこれから使用するのでインストール
RUN dnf install -y unzip

# 準備する資材のディレクトリ構成
#C:\IBM\MW
#+---IIM
#|   |   agent.installer.linux.gtk.x86_64_1.9.2008.20240227_0018.zip
#|   |
#|   \---configuration
#|       |   config.ini
#|       |   config.ini.backup
#|       |
#|       \---org.eclipse.update
#|               platform.xml
#|
#\---WAS
#        wlp-webProfile8-java8-linux-x86_64-24.0.0.6.zip

# IIM Installation
RUN mkdir /MW
RUN mkdir /MW/IIM
RUN mkdir /MW/logs

COPY /MW/IIM/agent.installer.linux.gtk.x86_64_1.9.2008.20240227_0018.zip /MW/IIM/agent.installer.linux.gtk.x86_64_1.9.2008.20240227_0018.zip 
RUN unzip /MW/IIM/agent.installer.linux.gtk.x86_64_1.9.2008.20240227_0018.zip -d /MW/IIM/


# IIMのインストールコマンド
RUN /MW/IIM/installc -acceptLicense -log /MW/logs/01.IIM_install.log

# インストール時にIHSの警告文を迂回するためのコンフィグファイル
COPY /MW/IIM/configuration/config.ini /opt/IBM/InstallationManager/eclipse/configuration/config.ini
RUN chmod +rwx /opt/IBM/InstallationManager/eclipse/configuration/config.ini

## IHSは手動でInstallation Managerを使用しインストール
# docker exec -it [コンテナ名] /bin/bash
# /opt/IBM/InstallationManager/eclipse/IBMIM
# Linux では、/opt/IBM/InstallationManager/eclipse/IBMIM コマンドを実行
# Installation Manager で、「ファイル」 > 「設定」 > 「リポジトリー」をクリック
# 「リポジトリーの追加」をクリックし、次の URL を入力
# https://www.ibm.com/software/repositorymanager/V85WASIHSILAN
# サポート→　https://www.ibm.com/docs/ja/api-connect/5.0.x?topic=connect-installing-http-server

## WAS Libertyに関しては開発者用の無償版をインストールする
RUN mkdir /MW/WAS
COPY /MW/WAS/wlp-webProfile8-java8-linux-x86_64-24.0.0.6.zip /MW/WAS/wlp-webProfile8-java8-linux-x86_64-24.0.0.6.zip
RUN unzip /MW/WAS/wlp-webProfile8-java8-linux-x86_64-24.0.0.6.zip -d /MW/WAS/
RUN chown -R /MW/WAS/
