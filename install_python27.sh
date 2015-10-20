#!/usr/bin/env bash
#
# Upgrade python to 2.7.10 on CentOS 5.6, 5.7 and 5.8
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
fallback_vers="2.7.10"
fallback_url="http://www.python.org/ftp/python/$fallback_vers/Python-$fallback_vers.tgz"


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

json_val() {
  KEY=$1
  awk -F"[\"]" '{for(i=1;i<=NF;i++){ if($i~/'$KEY'/){ print $(i+2) }}}'
}

python_info() {
  if [ "$usescriptio" == "true" ]; then
    OUT=$( curl -L -m 5 -qSfsw '\n%{http_code}' script.io/disks/python/python2 2>/dev/null )
    RET=$?
    STAT=$( echo "$OUT" | tail -n1 )
    RESP=$( echo "$OUT" | head -n-1 )

    if [[ ($RET -eq 0) && ("$STAT" == "200") ]]; then
      python2vers=$( echo $RESP | json_val version )
      python2url=$( echo $RESP | json_val url )
    fi
  fi

  if [[ -z "$python2vers" || -z "$python2url" ]]; then
    python2vers=$fallback_vers
    python2url=$fallback_url
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
  ./configure --prefix=${dest}/python$python2vers --with-threads --enable-shared --enable-unicode=ucs4 --with-ensurepip=install
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
      sed -i "1i ${dest}/python$python2vers/lib" /etc/ld.so.conf.d/local-lib.conf
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
  echo "Installing Fabric and Virtualenv"
  echo "---------------------------------------------------------------"
  echo ""

  export PATH=$PATH:/usr/bin:${dest}/python$python2vers/bin

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

