#!/usr/bin/env bash

mkdir -p ~/Apps
mkdir -p ~/tmp
wget -qO ~/tmp/prowlarr.tar.gz --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
tar -xvf ~/tmp/prowlarr.tar.gz -C ~/Apps
mkdir -p ~/.config/Prowlarr
randomPort="$(shuf -i 10001-32001 -n 1)"
echo "<Config>
  <Port>$randomPort</Port>
  <UrlBase>/$USER/prowlarr</UrlBase>
  <BindAddress>*</BindAddress>
  <SslPort>9696</SslPort>
  <EnableSsl>False</EnableSsl>
  <AuthenticationMethod>Forms</AuthenticationMethod>
  <LogLevel>info</LogLevel>
  <Branch>develop</Branch>
  <LaunchBrowser>False</LaunchBrowser>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <SslCertPath></SslCertPath>
  <SslCertPassword></SslCertPassword>
  <AuthenticationRequired>Enabled</AuthenticationRequired>
  <InstanceName>Prowlarr</InstanceName>
</Config>" > ~/.config/Prowlarr/config.xml

# Reverse proxy
echo "location /prowlarr/ {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_x_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_pass http://10.0.0.1:$randomPort/$USER/prowlarr;
    proxy_redirect off;
}" >~/.nginx/conf.d/000-default-server.d/prowlarr.conf
/usr/sbin/nginx -s reload -c ~/.nginx/nginx.conf 2>/dev/null

echo -e '[[ "$(pgrep -f '''Prowlarr''')" ]] || screen -dmS Prowlarr /bin/bash -c '''~/Apps/Prowlarr/Prowlarr''' ' >> ~/.cronscript.sh
