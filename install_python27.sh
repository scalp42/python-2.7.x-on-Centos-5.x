#!/bin/bash
#
# Upgrade python to 2.7.3 on CentOS 5.6, 5.7 and 5.8
# scalisi.a@gmail.com
#
#
# Syntax: #> ./install_python27.sh
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

clear ;

# Function: setup build tools
prepare() {

	echo ""
	echo "----------------------------------------------------"
	echo "Installing required packages..."
  	echo "----------------------------------------------------"
	echo ""
  	$yum gcc.x86_64 gdbm-devel.x86_64 readline-devel.x86_64 ncurses-devel.x86_64 zlib-devel.x86_64 bzip2-devel.x86_64
	$yum sqlite-devel.x86_64 db4-devel.x86_64 openssl-devel.x86_64 tk-devel.x86_64 bluez-libs-devel.x86_64 make.x86_64 python-devel.x86_64
	$yum wget unzip crypto-utils.x86_64 m2crypto.x86_64
	yum -y groupinstall 'Development Tools'
}

# Function: download sources
install() {

	echo ""
	echo "----------------------------------------------------"
	echo "Downloading sources and compiling..."
	echo "----------------------------------------------------"
	echo ""

	cd /tmp &&
	$wget http://www.sqlite.org/sqlite-autoconf-3071300.tar.gz &&
	tar xfz sqlite-autoconf-3071300.tar.gz &&
	cd sqlite-autoconf-3071300/ &&
	./configure
	make
	make install

	cd /tmp &&
	$wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz &&
	tar xzf Python-2.7.3.tgz &&
	cd Python-2.7.3 &&
	./configure --prefix=/opt/python2.7.3 --with-threads --enable-shared
	make
	make install

	touch /etc/ld.so.conf.d/opt-python2.7.3.conf
	echo "/opt/python2.7.3/lib/" >> /etc/ld.so.conf.d/opt-python2.7.3.conf
	echo "/usr/local/lib/" >> /etc/ld.so.conf.d/local-lib.conf
	/sbin/ldconfig &&

	ln -sf /opt/python2.7.3/bin/python2.7 /usr/bin/python2.7 &&
    ln -sf /opt/python2.7.3/bin/python2.7-config /usr/bin/python2.7-config
}

extra() {

	echo ""
	echo "---------------------------------------------------------------"
	echo "The more, the better... Installing Pip, Fabric and Virtualenv"
	echo "---------------------------------------------------------------"
	echo ""

    export PATH=$PATH:/usr/bin:/opt/python2.7.3/bin

	cd /tmp &&
	$wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg &&
	cd /opt/python2.7.3/lib/python2.7/config &&
	ln -s ../../libpython2.7.so . 
	ln -sf /opt/python2.7.3/lib/libpython2.7.so /usr/lib/libpython2.7.so ;
	/sbin/ldconfig &&
	sh /tmp/setuptools-0.6c11-py2.7.egg --prefix=/opt/python2.7.3

	/opt/python2.7.3/bin/easy_install pip
#	ln -sf /opt/python2.7.3/bin/pip /usr/bin/pip

	/opt/python2.7.3/bin/pip install virtualenv
#	ln -sf /opt/python2.7.3/bin/virtualenv /usr/bin/virtualenv

	/opt/python2.7.3/bin/pip install fabric
#	ln -sf /opt/python2.7.3/bin/fab /usr/bin/fab

}

cleaning() {

	echo "----------------------------------------------------"
	echo "French maid time... let's clean everything."
	echo "----------------------------------------------------"

	rm -fr /tmp/Python-2.7.3.tgz ;
	rm -fr /tmp/Python-2.7.3 ;
	rm -fr /tmp/setuptools-0.6c11-py2.7.egg ;
	rm -fr /tmp/sqlite-autoconf-* ;
	rm -fr /tmp/sqlite-autoconf-* ;

}

linking() {

	echo ""
	echo "------------------------------------------------------------------------"
	echo "Exporting python2.7.3 path to access binaries in /opt/python2.7.3/bin"
	echo "------------------------------------------------------------------------"
	echo ""

	echo 'export PATH=$PATH:/opt/python2.7.3/bin' >> ~/.bash_profile
}


prepare
install
extra
cleaning
linking

echo ""
echo "Done !"
echo ""
echo "Please report any issues on Github, https://github.com/scalp42/python-2.7.x-on-Centos-5.x/issues"
echo "Any feedback welcomed !"
echo ""