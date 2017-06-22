# #######################################################
# #
# # Ubuntu LTS 16.04 (ubuntu/xenial64)
# # 
# # Description: build script
# #  - https://wq.io/1.0/docs/setup-ubuntu
# #
# #######################################################

# Install system libraries
sudo apt-get update
sudo apt-get install -y apache2 libapache2-mod-wsgi-py3 postgresql-9.5-postgis-2.2 python3-venv python-pip nodejs-legacy

# Create project directory and venv
export PROJECTSDIR=/var/www #e.g. /var/www
export PROJECTNAME=ReportHub
export DOMAINNAME=192.168.33.26

cd $PROJECTSDIR
sudo mkdir $PROJECTNAME
sudo chown 'ubuntu' $PROJECTNAME
cd $PROJECTNAME
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip # optional

# Install wq 1.0.0rc1 within venv
pip install wq --pre
wq start $PROJECTNAME . -d $DOMAINNAME
sudo chown www-data media/ # give Apache user permission to save uploads

# Create database
# (edit /etc/postgresql/9.5/main/pg_hba.conf and/or pg_ident.conf to set permissions)
sudo sed -i "s/peer/md5/g" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i "s/local   all             postgres                                md5/local   all             postgres                                trust/g" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i "s/local   all             all                                     md5/local   all             all                                trust/g" /etc/postgresql/9.5/main/pg_hba.conf
sudo sed -i '$a host    all             all             0.0.0.0/0               trust' /etc/postgresql/9.5/main/pg_hba.conf
# sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.5/main/postgresql.conf
sudo service postgresql restart
createuser -U postgres $PROJECTNAME
createdb -U postgres -O $PROJECTNAME $PROJECTNAME
psql -U postgres $PROJECTNAME -c "CREATE EXTENSION postgis;"
pip install psycopg2

# Install database tables & create admin account
# (edit db/$PROJECTNAME/local_settings.py with database info, if different than above)
cd db/
./manage.py migrate
./manage.py createsuperuser

# Configure and restart Apache
# (edit conf/$PROJECTNAME.conf and verify settings)
sudo ln -s $PROJECTSDIR/$PROJECTNAME/conf/$PROJECTNAME.conf /etc/apache2/sites-available/
sudo a2ensite $PROJECTNAME
# optional: disable existing default site and make $PROJECTNAME the server default
sudo a2dissite 000-default
sudo ln -s /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/
# sudo a2enmod expires
sudo service apache2 restart

# generate htdocs folder via wq build
cd ../
./deploy.sh 0.0.1

# To Enable HTTPS:
# (edit conf/$PROJECTNAME.conf, comment out WSGIDaemonProcess line)
# (see https://github.com/certbot/certbot/issues/1820)
sudo apt-get install -y python-letsencrypt-apache
sudo a2enmod ssl
sudo letsencrypt
# (edit /etc/apache2/sites-enabled/$PROECTNAME-le-ssl.conf, uncomment WSGIDaemonProcess line)
