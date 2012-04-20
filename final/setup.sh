#!/bin/bash

sudo cp auth.war /var/lib/tomcat6/webapps
sudo service tomcat6 restart
sudo cp /var/lib/tomcat6/webapps/auth/WEB-INF/classes/blank-config.xml /var/lib/tomcat6/webapps/auth/WEB-INF/classes/config.xml

cp /var/lib/tomcat6/webapps/demo/bbb_api_conf.jsp /var/lib/tomcat6/webapps/auth

sudo cp auth.nginx /etc/bigbluebutton/nginx
sudo service nginx restart
