#!/bin/bash

cp /var/lib/tomcat6/webapps/demo/bbb_api_conf.jsp auth/WebContent/parts

sudo cp auth.nginx /etc/bigbluebutton/nginx
sudo service nginx restart
