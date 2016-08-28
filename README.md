# Bench

Bench is a simple utility script for managing docker-compose development environments.

### Dependencies
 - docker
 - docker-compose

### Installation

```sh
$ sudo -- sh -c 'curl -L https://raw.githubusercontent.com/dcole-inviqa/bench/master/bench > /usr/local/bin/bench; chmod +x /usr/local/bin/bench'
```

### Usage

```sh
$ git clone git@github.com:dcole-inviqa/docker-stack-php.git
$ cd docker-stack-php
$ bench start
Starting dockerstackphp_fpm_1
Starting dockerstackphp_mysql_1
Starting dockerstackphp_nginx_1
$ bench ipaddress
172.23.0.4 # Browsing to address will show a phpinfo page
```
