#!/bin/bash
sudo dnf install epel-release -y # memcache 설치(memcache의 경우 yum이 아닌 dnf 사용)
sudo dnf install memcached -y
sudo systemctl start memcached # memcache 서버 시작
sudo systemctl enable memcached # memcache 재시작
sudo systemctl status memcached # memcache 상태 확인
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached #원격으로 memcache에 연결하기 위함 = 모든 IP에서 연결
sudo systemctl restart memcached #memcache 재시작
firewall-cmd --add-port=11211/tcp 
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=11111/udp
firewall-cmd --runtime-to-permanent
sudo memcached -p 11211 -U 11111 -u memcached -d
