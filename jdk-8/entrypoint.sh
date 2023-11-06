#!/bin/sh
java -jar -DDBPASSWD=${DBPASSWD} -DDBHOST=${DBHOST} -DDBNAME=${DBNAME} -DDBUSERNAME=${DBUSERNAME} /opt/backend/app.jar