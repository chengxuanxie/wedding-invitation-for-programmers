#!/bin/bash
workdir=$(cd $(dirname $0); pwd)
echo ${workdir}
git pull origin
yarn install
yarn run build
echo 'build ok'
#sh /opt/xcx/apache-tomcat-7.0.94/bin/shutdown.sh
#sh /opt/xcx/apache-tomcat-7.0.94/bin/startup.sh
cp -rf ${workdir}/dist/* /opt/xcx/weddinginvitaion
/usr/local/nginx/sbin/nginx -s reload
echo 'start ok'
