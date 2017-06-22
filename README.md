# django-wqShell

> Django env with WQ

#### Requirements

- VirtualBox v5.0.10
- Vagrant v1.7.4


## Getting started

* Vagrant installs server environment

		$ git clone https://github.com/iMMAP-Afg/django-wqShell.git
		$ cd django-wqShell/vagrant
		$ vagrant up
* With mounted folders
		
		/vagrant => django-wqShell/vagrant
		/var/www => django-wqShell/www
		/var/data => django-wqShell/data

* Once built, enter the virtual machine with vagrant ssh

		$ vagrant ssh

* Run the commands in data/django.wq.shell.build.sh (```/var/data/django.wq.shell.build.sh```) to install Wq
