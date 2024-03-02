TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz" # tomcat package 다운로드
dnf -y install java-11-openjdk java-11-openjdk-devel # tomcat은 java에 종속되어 있으므로 자바 설치 필요
dnf install git maven wget -y # 종속성 설치
cd /tmp/ # 디렉토리 변경
wget $TOMURL -O tomcatbin.tar.gz # tomcat 파일 추출
EXTOUT=`tar xzvf tomcatbin.tar.gz` 
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
useradd --shell /sbin/nologin tomcat # 사용자명이 tomcat인 사용자 추가
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/ # 홈디렉토리 생성
chown -R tomcat.tomcat /usr/local/tomcat # tomcat사용자에 권한부여

rm -rf /etc/systemd/system/tomcat.service # 파일 및 디렉토리 삭제

cat <<EOT>> /etc/systemd/system/tomcat.service # tomcat.service 파일 생성
[Unit]
Description=Tomcat  
After=network.target

[Service]

User=tomcat
Group=tomcat

WorkingDirectory=/usr/local/tomcat

#Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh


RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

EOT

systemctl daemon-reload # /etc/systemd/system에 변경사항 있을 때마다 해당 명령어 실행
systemctl start tomcat
systemctl enable tomcat

git clone -b main https://github.com/hkhcoder/vprofile-project.git # 소스코드 배포
cd vprofile-project 
mvn install # 아티팩트(응용프로그램) 설치
systemctl stop tomcat # tomcat 서비스 정지 후 배포
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT* # 기존 응용프로그램 제거
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war # 설치한 응용프로그램 복사
systemctl start tomcat # tomcat 재시작
sleep 20
systemctl stop firewalld
systemctl disable firewalld
#cp /vagrant/application.properties /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat
