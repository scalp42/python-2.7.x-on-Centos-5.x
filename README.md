# Python 2.7.x on CentOS 5.x


## Description

Upgrade python (http://www.python.org/) to latest stable version without breaking yum on CentOS 5.x.

It also installs by **default** [pip](http://www.pip-installer.org/), [virtualenv](http://www.virtualenv.org/) and [fabric](http://docs.fabfile.org/), **but can be skipped**.

This script was tested on:

* CentOS 5.5 (i686)
* CentOS 5.6 (i686)
* CentOS 5.7 (x86_64)
* CentOS 5.8 (x86_64)

It's [idempotent](http://en.wikipedia.org/wiki/Idempotence#Computer_science_meaning) and cleanup after itself on exit **or** interrupt (^X^C).



## Requirements

This script has **only** been tested on CentOS 5.6, 5.7 and 5.8. 

**Please do NOT run it on CentOS 6.x (it should not be needed)**.

## Usage

You must be root or use sudo.

	#> ./install_python27.sh
	
You can edit `dest` in `install_python27.sh` to select destination path for python:

	dest="/usr/local"
	
If you **do not** wish to install python extras (pip, virtualenv and fabric), please set:
	
	install_extras="false"
	
Please make sure to add the path your environment, depending on your `dest` and python version, for example:

	export PATH=$PATH:/opt/python2.7.4/bin


## Todo
* allow Python 3 to be installed.



## Need Help or Want to Contribute ?

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

It is more important to me that you are able to contribute and get help if you need it.

That said, some basic guidelines, which you are free to ignore :)

- Have a problem you want this script to solve for you ? You can email me personally (scalisi.a@gmail.com)
- Have an idea or a feature request? File a ticket on Github, or email me personally (scalisi.a@gmail.com) if this is more comfortable.
- If you think you found a bug, it probably is a bug. Please file a ticket on Github.
- If you want to make it better, best way is to fork this repo and send me a pull request. If you don't know git, I also accept diff(1) formatted patches - whatever is most comfortable for you.

**Programming is not a required skill**. Whatever you've seen about open source with maintainers or community members saying "send patches or die" -  you will not see that here.



## License & Author:

Author:: Anthony Scalisi (scalisi.a@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Contributors:

* [dldinternet](https://github.com/dldinternet) for the suggestion about the path choice.
* [tthayer](https://github.com/tthayer) for fixing a 404 on sqlite-autoconf download and wrong paths on ldconfig libraries
* [Blaisorblade](https://github.com/Blaisorblade) for reporting a misleading error regarding Fabric and Virtualenv symlinks