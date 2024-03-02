# adding repository and installing nginx		
apt update # 업데이트
apt install nginx -y # nginx 설치
cat <<EOT > vproapp
upstream vproapp {

 server app01:8080;                   # tomcat 으로 연결

}

server {

  listen 80;

location / {

  proxy_pass http://vproapp;

}

}

EOT

mv vproapp /etc/nginx/sites-available/vproapp 
rm -rf /etc/nginx/sites-enabled/default # default 설정 파일 제거
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp # 새로운 설정파일 링크 생성

#starting nginx service and firewall
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
