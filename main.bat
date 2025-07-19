@echo off

REM ;/ argument for docker contaner name: DM_BASE_LOCAL
REM ;/ set container_name = %~1
set "container_name=DM_BASE_LOCAL"

REM ;/ variable for  docker image tag: rhel_test:1.0
set "image_tag=rhel_test:1.0"

echo "Please make sure to open the Docker desktop application">con
echo "this operation requires 'docker login'">con

REM ;/ Dockerコンテナを作成するためにディレクトリ移動
REM ;/ Pull the official Redhat Docker image
docker pull redhat/ubi9

REM ;/ Build Docker image
docker build -t %image_tag% .

REM ;/ Need to add image tag
docker tag redhat/ubi9 %image_tag%

REM ;/ Push Docker image to a registry 
docker push %image_tag%

REM ;/ Run the container *make sure you have the docker-compose.yml file
docker run --name %container_name% -d %image_tag%

REM ;/ Start Installation Manager on the container
docker exec -it %container_name% /bin/bash -c "/opt/IBM/InstallationManager/eclipse/IBMIM"

timeout /t 10

