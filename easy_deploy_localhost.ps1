# easy_deploy_localhost.ps1

# Variables
$openlibertyContainer = "openliberty_app"
$db2Container = "db2"

Write-Output "📦 Copying files and starting OpenLiberty app..."
docker exec $openlibertyContainer /opt/ol/wlp/bin/server create testdb
docker exec $openlibertyContainer mkdir -p /opt/ol/wlp/usr/servers/testdb/dropins

docker cp ./MW/OL/app.war "${openlibertyContainer}:/opt/ol/wlp/usr/servers/testdb/dropins/app.war"
docker cp ./MW/OL/jvm.options "${openlibertyContainer}:/opt/ol/wlp/usr/servers/testdb/jvm.options"
docker cp ./MW/OL/server.xml "${openlibertyContainer}:/opt/ol/wlp/usr/servers/testdb/server.xml"

docker exec $openlibertyContainer /opt/ol/wlp/bin/server start testdb

Write-Output "📦 Setting up DB2 container..."

docker exec $db2Container /var/db2_setup/lib/setup_db2_instance.sh
docker exec $db2Container su - db2inst1 -c "db2start"
docker exec $db2Container su - db2inst1 -c "db2 connect to testdb"
docker cp ./DB2/DDL/init.sql "${db2Container}:/docker-entrypoint-initdb.d/init.sql"
docker exec $db2Container su - db2inst1 -c "db2 -tvf /docker-entrypoint-initdb.d/init.sql"

Write-Output "✅ Deployment complete."
