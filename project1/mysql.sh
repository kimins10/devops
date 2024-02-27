#!/bin/bash
DATABASE_PASS='admin123'
sudo yum update -y #  OS 업데이트
sudo yum install epel-release -y #  패키지 접근 위한 repository 설치
sudo yum install git zip unzip -y 
sudo yum install mariadb-server -y #maria db 패키지 설치(Maria DB:  MySQL 기반의 오픈소스 관계형 RDBMS)


# starting & enabling mariadb-server
sudo systemctl start mariadb # Maria DB 서버 시작
sudo systemctl enable mariadb # Maria DB 활성화
cd /tmp/ # 
git clone -b main https://github.com/hkhcoder/vprofile-project.git #  Github 소스코드 복제
#restore the dump file for the application
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'" # DB에 대한 모든 권한을 사용자에게 부여('%'는 원격에서 접속 가능)
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql #Github에 있는 파일 내용 데이터베이스에 적용
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES" # 권한 변경사항 적용

# Restart mariadb-server
sudo systemctl restart mariadb # Maria DB 재시작


#starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
