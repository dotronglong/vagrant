#!/bin/sh

# Disable SELinux
cat <<EOT > /etc/sysconfig/selinux
SELINUX=disabled
SELINUXTYPE=targeted
EOT

# Install necessary tools
yum install -y wget vim git unzip

# Install apache-2.4.*
curl -SLo /etc/yum.repos.d/epel-httpd24.repo https://repos.fedorapeople.org/repos/jkaluza/httpd24/epel-httpd24.repo
yum install -y httpd httpd-devel httpd-tools
systemctl enable httpd
systemctl enable httpd
mkdir /var/www/tools

# Install MariaDB-10.1
yum remove -y mariadb-*
cat <<EOT > /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.1 CentOS repository list - created 2017-04-20 03:51 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOT
yum install -y MariaDB-server MariaDB-client
systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation
/vagrant/db.sh init

# Install php-7.1
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install -y --skip-broken php71w-* mod_php71w
cat <<EOT > /etc/httpd/conf.modules.d/10-php.conf
<IfModule prefork.c>
  LoadModule php7_module modules/libphp7.so
</IfModule>

<IfModule !prefork.c>
  LoadModule php7_module modules/libphp7-zts.so
</IfModule>
EOT
cat <<EOT > /etc/httpd/conf.d/php.conf
<IfModule mime_module>
  AddType application/x-httpd-php .php
</IfModule>
EOT
cat <<EOT > /etc/php.d/core.ini
display_errors = On
error_reporting = E_ALL
error_log = /var/log/php.log
max_input_time = 180
max_execution_time = 120
memory_limit = 1024
upload_max_filesize = 200M
post_max_size = 300M
EOT

# Install phpMyAdmin 4.7.0
curl -SLO https://files.phpmyadmin.net/phpMyAdmin/4.7.0/phpMyAdmin-4.7.0-english.zip
unzip phpMyAdmin-4.7.0-english.zip
rm -rf phpMyAdmin-4.7.0-english.zip
cat <<EOT > phpMyAdmin-4.7.0-english/config.inc.php
<?php
$cfg['blowfish_secret'] = 'Dplayi6FaWtbQp4YUOi2peL91TkBTP3j';
$i = 0;
$i++;
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
EOT
mv phpMyAdmin-4.7.0-english /var/www/tools/phpmyadmin
cat <<EOT > /etc/httpd/conf.d/alias.conf
Alias /phpmyadmin /var/www/tools/phpmyadmin
EOT
cat <<EOT > /etc/httpd/conf.d/phpmyadmin.conf
<Directory "/var/www/tools/phpmyadmin">
  DirectoryIndex index.php
  AllowOverride FileInfo AuthConfig Limit Indexes
  Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
  Require method GET POST OPTIONS
</Directory>
EOT
