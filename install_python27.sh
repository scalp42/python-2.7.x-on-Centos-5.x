#!/usr/bin/env bash
#
# Upgrade python to 2.7.8 on CentOS 5.6, 5.7 and 5.8
# scalisia@gmail.com
#
#
# Syntax: #> ./install_python27.sh
#

# int main()

## This variable enables the use of script.io disks endpoint.
## Please visit script.io/disks/python for more information.
## Set it to "false" to deactivate.
usescriptio="true"

## This variable specifies the path for the new binaries
dest="/opt"

## This variable specifies if extras need to be installed
install_extras="true"

## The following fallback variables are only used if script.io is disabled and/or unreachable
fallback_vers="2.7.8"
fallback_url="http://www.python.org/ftp/python/$fallback_vers/Python-$fallback_vers.tgz"
fallback_setuptools_vers="0.6c11"
fallback_setuptools_url="https://pypi.python.org/packages/2.7/s/setuptools/setuptools-$fallback_setuptools_vers-py2.7.egg#md5=fe1f997bc722265116870bc7919059ea"


if [ "$(id -u)" != "0" ]; then
        echo "Gotta be root to run this script."
        echo "Syntax: sudo $0"
        exit 1
fi

yum="yum -y -q install"
wget="wget --no-check-certificate"
arch=`uname -i`
tmpdir=`mktemp -d`
trap 'printf "\n\nLooks like the script exited or got interrupted, cleaning up.\n\n"; python_clean' INT TERM EXIT

sqliteautoconf="sqlite-autoconf-3071602"
sqlitesrc="http://www.sqlite.org/2013/$sqliteautoconf.tar.gz"

clear ;

python_info() {
  if [ "$usescriptio" == "true" ]; then
    STATUS_SCRIPTIO=`curl -L -m 5 --output /dev/null --silent --head --write-out '%{http_code}\n' script.io/disks/python/python2/version`
    if [ "$STATUS_SCRIPTIO" == "200" ]; then
      python2vers=$(curl -L -m 5 --silent script.io/disks/python/python2/version | tr -d '"')
      python2url=$(curl -L -m 5 --silent script.io/disks/python/python2/url | tr -d '"')
      setuptoolsvers=$(curl -L -m 5 --silent script.io/disks/setuptools/2.7/version | tr -d '"')
      setuptoolsurl=$(curl -L -m 5 --silent script.io/disks/setuptools/2.7/url | tr -d '"')
    else
      python2vers=$fallback_vers
      python2url=$fallback_url
      setuptoolsvers=$fallback_setuptools_vers
      setuptoolsurl=$fallback_setuptools_url
    fi
  else
    python2vers=$fallback_vers
    python2url=$fallback_url
    setuptoolsvers=$fallback_setuptools_vers
    setuptoolsurl=$fallback_setuptools_url
  fi
}

python_prepare() {

  echo ""
  echo "----------------------------------------------------"
  echo "Installing required packages..."
  echo "----------------------------------------------------"
  echo ""
  yum -q check-update ;
  $yum gcc.${arch} gdbm-devel.${arch} readline-devel.${arch} ncurses-devel.${arch} zlib-devel.${arch} bzip2-devel.${arch}
  $yum sqlite-devel.${arch} db4-devel.${arch} openssl-devel.${arch} tk-devel.${arch} bluez-libs-devel.${arch} make.${arch} python-devel.${arch}
  $yum wget curl unzip crypto-utils.${arch} m2crypto.${arch}
  yum -y -q groupinstall 'Development Tools'
}

python_install() {

  echo ""
  echo "----------------------------------------------------"
  echo "Downloading sources and compiling..."
  echo "----------------------------------------------------"
  echo ""

  cd $tmpdir &&
  $wget $sqlitesrc &&
  tar xfz $sqliteautoconf.tar.gz &&
  cd $sqliteautoconf &&
  ./configure
  make
  make install

  cd $tmpdir &&
  $wget $python2url &&
  tar xzf Python-$python2vers.tgz &&
  cd Python-$python2vers &&
  ./configure --prefix=${dest}/python$python2vers --with-threads --enable-shared --enable-unicode=ucs4
  make
  make install

  if [ -f /etc/ld.so.conf.d/opt-python$python2vers.conf ]; then
    rm -f /etc/ld.so.conf.d/opt-python$python2vers.conf
  fi
  touch /etc/ld.so.conf.d/opt-python$python2vers.conf
  echo "${dest}/python$python2vers/lib" >> /etc/ld.so.conf.d/opt-python$python2vers.conf
  if [ -f /etc/ld.so.conf.d/local-lib.conf ]; then
    if grep -qio "${dest}/python$python2vers/lib" /etc/ld.so.conf.d/local-lib.conf; then
      true
    else
      echo "${dest}/python$python2vers/lib" >> /etc/ld.so.conf.d/local-lib.conf
    fi
  else
    echo "${dest}/python$python2vers/lib" >> /etc/ld.so.conf.d/local-lib.conf
  fi
  /sbin/ldconfig &&

  ln -sf ${dest}/python$python2vers/bin/python2.7 /usr/bin/python2.7 &&
  ln -sf ${dest}/python$python2vers/bin/python2.7-config /usr/bin/python2.7-config
}

python_extra() {

  echo ""
  echo "---------------------------------------------------------------"
  echo "Installing Pip, Fabric and Virtualenv"
  echo "---------------------------------------------------------------"
  echo ""

  export PATH=$PATH:/usr/bin:${dest}/python$python2vers/bin

  cd $tmpdir &&
  $wget $setuptoolsurl &&
  cd ${dest}/python$python2vers/lib/python2.7/config &&
  ln -s ../../libpython2.7.so .
  ln -sf ${dest}/python$python2vers/lib/libpython2.7.so /usr/lib/libpython2.7.so ;
  /sbin/ldconfig &&
  sh $tmpdir/setuptools-$setuptoolsvers-py2.7.egg --prefix=${dest}/python$python2vers

  ${dest}/python$python2vers/bin/easy_install pip
  #ln -s ${dest}/python$python2vers/bin/pip ${dest}/bin/pip

  ${dest}/python$python2vers/bin/pip install virtualenv
  #ln -s ${dest}/python$python2vers/bin/virtualenv ${dest}/bin/virtualenv

  ${dest}/python$python2vers/bin/pip install fabric
  #ln -s ${dest}/python$python2vers/bin/fab ${dest}/bin/fab

  exit 42
}

python_clean() {
  if [ -d "$tmpdir" ]; then
    rm -fr $tmpdir ;
    exit 0
  fi
}

python_prepare
python_info
python_install
if [ "$install_extras" == "true" ]; then
  python_extra
fi
