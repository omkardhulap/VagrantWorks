#!/bin/bash
echo "installing apache"
apt-get update >/dev/null 2>&1
apt-get install -y apache2 >/dev/null 2>&1

cp /tmp/site.conf /etc/apache2/sites-available/site.conf > /dev/null
a2ensite site.conf > /dev/null

#echo "installing apache security config"
#apt-get update >/dev/null 2>&1
#apt-get install apache2-utils >/dev/null 2>&1
#whereis htpasswd
#sudo htpasswd -b -c /etc/apache2/.htpasswd admin admin

echo "Hi, I am learning right now. I'm just an example of how to evolve provisioning with shell scripts."
service apache2 start  1>&2 > /dev/null  # I lied
netstat -ap | grep apache2

echo "install memcache dependancy"
type whereis libevent
wget http://www.monkey.org/~provos/libevent-1.4.8-stable.tar.gz
tar xfz libevent-1.4.8-stable.tar.gz
cd libevent-1.4.8-stable
./configure && make && sudo make install
sudo ln -s /usr/local/lib/libevent-1.4.so.2 /usr/lib

echo "install memcache"
wget https://memcached.org/files/memcached-1.4.31.tar.gz
echo | tar -zxvf memcached-1.4.31.tar.gz
cd memcached-1.4.31
./configure && make && make test && sudo make install

echo "run memcache as demon"
memcached -d -m 4096 -u root -l 127.0.0.1 -p 11211

echo "checking memcache running"
netstat -ap | grep 11211

echo "Cron Script executed from: ${PWD}"
ls -lrt
value=$(<exercise-memcached.sh)
echo "$value"
whereis bash
PATH="$PATH":/home/vagrant
* * * * * /bin/bash ./exercise-memcached.sh

echo "checking memcache stats >>"
echo stats | nc 127.0.0.1 11211

#echo "Installing memcached stats monitoring tool"
#wget http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz
#tar xfz phpMemcachedAdmin-1.2.2-r262.tar.gz -C /var/www/phpMemcachedAdmin
#chmod +rx *
#chmod 0777 /var/www/phpMemcachedAdmin/Config/Memcache.php
#chmod 0777 /var/www/phpMemcachedAdmin/Temp/
#chmod 0777 /var/www/phpMemcachedAdmin
#mv /home/vagrant/phpMemcachedAdmin.conf /etc/apache2/sites-enabled
#echo "I screwed-up"

pip install flask

#sudo apt-get install -y python-memcache
#sudo apt-get install -y rrdtool
#pip install 'git+git://github.com/omkardhulap/FakingMonkey/blob/master/monitoring/memcached_stats_rrd.py'
#chmod 0777 /home/vagrant/memcached_stats_rrd.py
#cp /home/vagrant/memcached_stats_rrd.py /var/www/memcached_stats_rrd.py > /dev/null
#*/1 * * * * /var/www/memcached_stats_rrd.py
#echo "I screwed-up more"

sudo apt-get update
sudo apt-get install git	# no space to install git and test further
pip install 'git+git://github.com/dlrust/python-memcached-stats.git'
python -m memcached_stats 127.0.0.1 11211

echo "replace modified app.py file"
chmod 0777 /home/vagrant/app.py
cp /home/vagrant/app.py /var/www/app/app.py # yet to test modified file

service apache2 restart