#!/bin/bash
#
# Update python to 2.7.2 on CentOS 5.7
# anthony.scalisi@blackboard.com
#
#
# Syntax: # ./install_python27.sh
#

# int main()
if [ "$(id -u)" != "0" ]; then
        echo "Gotta be root to run this script."
        echo "Syntax: sudo $0"
        exit 1
fi

# Aliases make me happy
yum="yum -y install"
wget="wget --no-check-certificate"

# Function: setup build tools
prepare() {

	echo "----------------------------------------------------"
	echo "Installing required packages..."
	echo ""
  	echo "If things go wrong, feel free to ask Obiwan, using the following syntax :"
  	echo "#> Help me, Obi-Wan Kenobi. You're my only hope."
	echo ""
  	echo "----------------------------------------------------"
  	$yum gcc.x86_64 gdbm-devel.x86_64 readline-devel.x86_64 ncurses-devel.x86_64 zlib-devel.x86_64 bzip2-devel.x86_64 unzip.x86_64 htop.x86_64 iotop sqlite-devel.x86_64 db4-devel.x86_64 openssl-devel.x86_64 tk-devel.x86_64 bluez-libs-devel.x86_64 make.x86_64 python-devel.x86_64
}

# Function: download sources
install() {

	echo "----------------------------------------------------"
	echo "Downloading sources and installing them..."
	echo "----------------------------------------------------"

	cd /tmp
	$wget http://www.sqlite.org/sqlite-autoconf-3071000.tar.gz
	tar xfz sqlite-autoconf-3071000.tar.gz
	cd sqlite-autoconf-3071000/
	./configure
	make
	make install

	cd /tmp
	$wget http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz
	tar xzf Python-2.7.2.tgz
	cd Python-2.7.2
	./configure --prefix=/opt/python2.7.2 --with-threads --enable-shared
	make
	make install

	touch /etc/ld.so.conf.d/opt-python2.7.2.conf
	echo "/opt/python2.7.2/lib/" >> /etc/ld.so.conf.d/opt-python2.7.2.conf
	echo "/usr/local/lib/" >> /etc/ld.so.conf.d/local-lib.conf
	ldconfig

	ln -sf /opt/python2.7.2/bin/python /usr/bin/python2.7
}

extra() {
	
	echo ""
	echo "----------------------------------------------------"
	echo "The more, the better... Installing easy_install, pip, virtualenv and fabric (because capistrano is in ruby)"
	echo "----------------------------------------------------"
	echo ""

	cd /tmp
	$wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg
	sh setuptools-0.6c11-py2.7.egg --prefix=/opt/python2.7.2

	/opt/python2.7.2/bin/easy_install pip
	ln -sf /opt/python2.7.2/bin/pip /usr/bin/pip

	pip install virtualenv
	ln -sf /opt/python2.7.2/bin/virtualenv /usr/bin/virtualenv

	pip install fabric
	ln -sf /opt/python2.7.2/bin/fab /usr/bin/fab

}

#mv /usr/bin/python /usr/bin/python-backup
#ln -s /usr/bin/python2.7 /usr/bin/python

cleaning() {

	echo "----------------------------------------------------"
	echo "French maid time... let's clean everything."
	echo "----------------------------------------------------"

	rm -fr /tmp/Python-2.7.2.tgz ;
	rm -fr /tmp/Python-2.7.2 ;
	rm -fr /tmp/setuptools-0.6c11-py2.7.egg ;
	rm -fr /tmp/sqlite-autoconf-3071000.tar.gz ;
	rm -fr /tmp/sqlite-autoconf-3071000 ;

}

linking() {

	echo ""
	echo "----------------------------------------------------"
	echo "Let's create some links for empty bash profile users out there."
	echo "----------------------------------------------------"
		
	ln -sf /opt/python2.7.2/bin/pydoc /usr/bin/pydoc ;
	ln -sf /opt/python2.7.2/bin/easy_install /usr/bin/easy_install
}


prepare
install
extra
cleaning
linking

echo ""
echo "Done !""
echo ""
