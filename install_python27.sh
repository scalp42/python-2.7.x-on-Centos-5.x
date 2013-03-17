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
arch="i386"
dest="/usr/local"

clear ;

# Function: setup build tools
prepare() {

	echo ""
	echo "----------------------------------------------------"
	echo "Installing required packages..."
  	echo "----------------------------------------------------"
	echo ""
  	$yum gcc.${arch} gdbm-devel.${arch} readline-devel.${arch} ncurses-devel.${arch} zlib-devel.${arch} bzip2-devel.${arch}
	$yum sqlite-devel.${arch} db4-devel.${arch} openssl-devel.${arch} tk-devel.${arch} bluez-libs-devel.${arch} make.${arch} python-devel.${arch}
	$yum wget unzip crypto-utils.${arch} m2crypto.${arch}
	yum -y groupinstall 'Development Tools'
}

# Function: download sources
install() {

	echo ""
	echo "----------------------------------------------------"
	echo "Downloading sources and compiling..."
	echo "----------------------------------------------------"
	echo ""

	#cd /tmp &&
	$wget http://www.sqlite.org/sqlite-autoconf-3071300.tar.gz &&
	tar xfz sqlite-autoconf-3071300.tar.gz &&
	cd sqlite-autoconf-3071300/ &&
	./configure
	make
	make install

	#cd /tmp &&
	$wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz &&
	tar xzf Python-2.7.3.tgz &&
	cd Python-2.7.3 &&
	./configure --prefix=${dest}/python2.7.3 --with-threads --enable-shared
	make
	make install

	touch /etc/ld.so.conf.d/opt-python2.7.3.conf
	echo "${dest}/python2.7.3/lib/" >> /etc/ld.so.conf.d/opt-python2.7.3.conf
	echo "/usr/local/lib/" >> /etc/ld.so.conf.d/local-lib.conf
	/sbin/ldconfig &&

	ln -sf ${dest}/python2.7.3/bin/python2.7 /usr/bin/python2.7 &&
    ln -sf ${dest}/python2.7.3/bin/python2.7-config /usr/bin/python2.7-config
}

extra() {

	echo ""
	echo "---------------------------------------------------------------"
	echo "The more, the better... Installing Pip, Fabric and Virtualenv"
	echo "---------------------------------------------------------------"
	echo ""

    export PATH=$PATH:/usr/bin:${dest}/python2.7.3/bin

	cd /tmp &&
	$wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg &&
	cd ${dest}/python2.7.3/lib/python2.7/config &&
	ln -s ../../libpython2.7.so . 
	ln -sf ${dest}/python2.7.3/lib/libpython2.7.so /usr/lib/libpython2.7.so ;
	/sbin/ldconfig &&
	sh /tmp/setuptools-0.6c11-py2.7.egg --prefix=${dest}/python2.7.3

	${dest}/python2.7.3/bin/easy_install pip
	ln -sf ${dest}/python2.7.3/bin/pip ${dest}/bin/pip

	${dest}/python2.7.3/bin/pip install virtualenv
	ln -sf ${dest}/python2.7.3/bin/virtualenv ${dest}/bin/virtualenv

	${dest}/python2.7.3/bin/pip install fabric
	ln -sf ${dest}/python2.7.3/bin/fab ${dest}/bin/fab

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
	echo "Exporting python2.7.3 path to access binaries in ${dest}/python2.7.3/bin"
	echo "------------------------------------------------------------------------"
	echo ""

	echo "export PATH=$\PATH:${dest}/python2.7.3/bin" >> ~/.bash_profile
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
