#!/bin/sh
MYSQL_ROOT_PASSWORD="123456"

say() { echo >&1 -e ":: $*"; }
info() { echo >&1 -e ":: \033[01;32m$*\033[00m"; }
warn() { echo >&2 -e ":: \033[00;31m$*\033[00m"; }
die() { echo >&2 -e ":: \033[00;31m$*\033[00m"; exit 1; }
null() { echo >/dev/null; }

function setup() {
  # Setup Google DNS
  # echo "nameserver 8.8.8.8" > /etc/resolv.conf
  # echo "nameserver 8.8.4.4" >> /etc/resolv.conf

  # Setup Cloudflare DNS
  echo "nameserver 1.1.1.1" > /etc/resolv.conf
  echo "nameserver 1.0.0.1" >> /etc/resolv.conf

  # Install Public Key
  cat /vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

  # Disable SELinux
  info "Set Up SELinux"
  cp -pr /vagrant/ops/etc/sysconfig/selinux /etc/sysconfig/selinux

  # Install necessary tools
  command="yum install -y wget curl vim git unzip"
  info $command && eval $command

  # Repos
  cp -pr /vagrant/ops/yum.repos.d/* /etc/yum.repos.d/
}

function install_system_tools() {
  install_netstat
  install_nmap
}

function install_netstat() {
  yum install -y net-tools
}

function install_nmap() {
  yum install -y nmap
}

function install_nfsd() {
  info "Installing NFS"
  systemctl enable rpcbind
  systemctl enable nfs-server
}

function install_nginx() {
  info "Installing Nginx"
  yum install -y epel-release
  command="yum install -y nginx httpd-tools"
  info $command && eval $command
  cp -pr /vagrant/ops/nginx/nginx.conf /etc/nginx/nginx.conf
  cp -pr /vagrant/ops/nginx/conf.d/* /etc/nginx/conf.d/
  systemctl enable nginx
  systemctl start nginx
}

function install_nginx_phpmyadmin() {
  mkdir /var/www/tools
  install_phpmyadmin
  ln -s /var/www/tools/phpmyadmin /var/www/html/phpmyadmin
}

function install_httpd() {
  info "Installing Apache"
  command="yum install -y httpd httpd-devel httpd-tools"
  info $command && eval $command

  cp -pr /vagrant/ops/httpd/conf/httd.conf /etc/httpd/conf/httpd.conf
  cp -pr /vagrant/ops/httpd/conf.d/* /etc/httpd/conf.d/
  systemctl enable httpd
  systemctl start httpd
  mkdir /var/www/tools
}

function install_mariadb() {
  info "Installing MariaDB"
  yum remove -y mariadb-*
  rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
  command="yum install -y MariaDB-server MariaDB-client"
  info $command && eval $command
  systemctl enable mariadb
  systemctl start mariadb
  mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
  mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'root'@'%';"
  mysql -e "FLUSH PRIVILEGES;"
}

function install_php() {
  info "Installing PHP"
  rpm -Uvh /vagrant/ops/rpm/epel-release-latest-7.noarch.rpm
  rpm -Uvh /vagrant/ops/rpm/webtatic-release.rpm
  command="yum install -y --skip-broken php71w-* mod_php71w"
  info $command && eval $command
  cp -pr /vagrant/ops/php/conf.d/10-php.conf /etc/httpd/conf.modules.d/10-php.conf
  cp -pr /vagrant/ops/php/php.d/* /etc/php.d/
}

function install_fpm() {
  install_php
  cp -pr /vagrant/ops/php-fpm.d/* /etc/php-fpm.d/
  systemctl enable php-fpm
  systemctl start php-fpm
}

function install_phpmyadmin() {
  info "Installing phpMyAdmin"
  curl -SLO https://files.phpmyadmin.net/phpMyAdmin/4.7.0/phpMyAdmin-4.7.0-english.zip
  unzip phpMyAdmin-4.7.0-english.zip
  rm -rf phpMyAdmin-4.7.0-english.zip
  mv phpMyAdmin-4.7.0-english phpmyadmin
  cp -pr /vagrant/ops/phpmyadmin/config.inc.php phpmyadmin/config.inc.php
  mv phpmyadmin /var/www/tools/phpmyadmin

  echo "Alias /phpmyadmin /var/www/tools/phpmyadmin" >> /etc/httpd/conf.d/alias.conf
  cp -pr /vagrant/ops/phpmyadmin/phpmyadmin.conf /etc/httpd/conf.d/phpmyadmin.conf
}

function install_composer() {
  info "Installing Composer"
  curl -SLO https://getcomposer.org/composer.phar
  chmod +x composer.phar
  mv composer.phar /usr/local/bin/composer
}

function install_node() {
  info "Installing NodeJS"
  curl -SLO https://nodejs.org/dist/v7.9.0/node-v7.9.0-linux-x64.tar.xz
  tar -xf node-v7.9.0-linux-x64.tar.xz
  rm -rf node-v7.9.0-linux-x64.tar.xz
  mv node-v7.9.0-linux-x64 /usr/local/share/node
  echo 'export PATH=$PATH:/usr/local/share/node/bin' >> /etc/profile
  export PATH=$PATH:/usr/local/share/node/bin
}

function install_bower() {
  export PATH=$PATH:/usr/local/share/node/bin
  info "Installing Bower"
  command="npm install -g bower"
  info $command && eval $command
}

function install_gulp() {
  export PATH=$PATH:/usr/local/share/node/bin
  info "Installing Gulp"
  command="npm install -g gulp"
  info $command && eval $command
}

function install_docker_ce() {
  info "Installing Docker CE"
  yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
  yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce

  # groupadd docker
  usermod -aG docker vagrant

  systemctl enable docker
  systemctl start docker
}

function install_docker_compose() {
  DC="docker-compose-`uname -s`-`uname -m`"
  DC_VER="1.16.1"
  info "Installing Docker Compose $DC_VER"
  curl -SLO https://github.com/docker/compose/releases/download/$DC_VER/$DC

  chmod +x $DC
  mv $DC /usr/local/bin/docker-compose
}

function install_buddy_ci() {
  info "Installing Buddy CI"
  rm -rf ~/.buddy
  curl -sSL https://get.buddy.works | sh && buddy install
}

function install_ngrok() {
  info "Installing ngrok"
  NGROK_FILE="ngrok-stable-linux-amd64.zip"
  NGROK_LINK="https://bin.equinox.io/c/4VmDzA7iaHb/$NGROK_FILE"
  curl -SLO $NGROK_LINK

  unzip $NGROK_FILE && rm -rf $NGROK_FILE
  chmod +x ngrok
  mv ngrok /usr/local/bin/ngrok
}

function install_jre() {
  JRE_VER=8u151-linux-x64
  JRE_URL=https://github.com/dotronglong/jre/raw/master/jre-$JRE_VER.rpm
  info "Installing JRE $JRE_VER"
  rpm -ivh $JRE_URL
}

function install_gocd_repo() {
  info "Installing GoCD repository"
  cp -pr /vagrant/ops/gocd/gocd.repo /etc/yum.repos.d/gocd.repo
}

function install_gocd_server() {
  GOCD_VER=17.10.0-5380
  GOCD_URL=https://download.gocd.org/binaries/$GOCD_VER/rpm/go-server-$GOCD_VER.noarch.rpm
  info "Installing GoCD $GOCD_VER"
  mkdir -p /var/go
  rpm -ivh $GOCD_URL
  systemctl enable go-server
}

function install_gocd_client() {
  GOCD_VER=17.10.0-5380
  GOCD_URL=https://download.gocd.org/binaries/$GOCD_VER/rpm/go-agent-$GOCD_VER.noarch.rpm
  info "Installing GoCD Client $GOCD_VER"
  mkdir -p /var/go
  rpm -ivh $GOCD_URL
  systemctl enable go-agent
}

function install_gocd_nginx() {
  install_nginx
  \cp -pr /vagrant/ops/gocd/gocd.conf /etc/nginx/conf.d/default.conf
}

function install_jenkins() {
  info "Installing Jenkins"
  wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  yum install -y jenkins
  systemctl enable jenkins
  systemctl start jenkins
}

function install_jenkins_nginx() {
  install_nginx
  \cp -pr /vagrant/ops/jenkins/default.conf /etc/nginx/conf.d/default.conf
}

function install_etcd() {
  ETCD_VER=v3.2.9

  GOOGLE_URL=https://storage.googleapis.com/etcd
  GITHUB_URL=https://github.com/coreos/etcd/releases/download
  DOWNLOAD_URL=${GOOGLE_URL}

  rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
  tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1

  ETCD_DIR=/var/lib/etcd
  mv /tmp/etcd-download-test $ETCD_DIR

  $ETCD_DIR/etcd --version
  <<COMMENT
  etcd Version: 3.2.9
  Git SHA: f1d7dd8
  Go Version: go1.8.4
  Go OS/Arch: linux/amd64
COMMENT

  ETCDCTL_API=3 $ETCD_DIR/etcdctl version
  <<COMMENT
  etcdctl version: 3.2.9
  API version: 3.2
COMMENT

  echo "export PATH=$PATH:$ETCD_DIR" > /etc/profile.d/etcd.sh
}
$*
