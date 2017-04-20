#!/bin/sh
MYSQL_ROOT_PASSWORD='123456'

function init() {
  mysql -uroot -e \
    "CREATE USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

  mysql -uroot -e \
    "GRANT ALL PRIVILEGES ON * . * TO 'root'@'%';"

  mysql -uroot -e \
    "FLUSH PRIVILEGES;"
}
$*
