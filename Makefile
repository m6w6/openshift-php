all: php/lib/libphp5.so

pcre-8.33/configure:
	curl http://softlayer-dal.dl.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.bz2 | tar xj
pcre-8.33/config.status: pcre-8.33/configure
	cd pcre-8.33 && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/pcre --disable-cpp --enable-unicode-properties
pcre-8.33/Makefile: pcre-8.33/config.status
	cd pcre-8.33 && ./config.status
pcre/lib/libpcre.so: pcre-8.33/Makefile
	cd pcre-8.33 && make -s -j3 install V=0
apr-1.4.8/configure:
	curl http://tweedo.com/mirror/apache//apr/apr-1.4.8.tar.bz2 | tar xj
apr-1.4.8/config.status: apr-1.4.8/configure
	cd apr-1.4.8 && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/apr --enable-nonportable-atomics
apr-1.4.8/Makefile: apr-1.4.8/config.status
	cd apr-1.4.8 && ./config.status
apr/lib/libapr-1.so: apr-1.4.8/Makefile
	cd apr-1.4.8 && make -s -j3 install V=0
apr-util-1.5.2/configure:
	curl http://tweedo.com/mirror/apache//apr/apr-util-1.5.2.tar.bz2 | tar xj
apr-util-1.5.2/config.status: apr-util-1.5.2/configure
	cd apr-util-1.5.2 && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/apu --with-apr=$(OPENSHIFT_DATA_DIR)/apr
apr-util-1.5.2/Makefile: apr-util-1.5.2/config.status
	cd apr-util-1.5.2 && ./config.status
apu/lib/libaprutil-1.so: apr-util-1.5.2/Makefile
	cd apr-util-1.5.2 && make -s -j3 install V=0
httpd-2.4.6/configure:
	curl http://tweedo.com/mirror/apache//httpd/httpd-2.4.6.tar.bz2 | tar xj
httpd-2.4.6/config.status: pcre/lib/libpcre.so apu/lib/libaprutil-1.so apr/lib/libapr-1.so httpd-2.4.6/configure
	cd httpd-2.4.6 &&  ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/httpd --enable-so --enable-http --enable-rewrite --with-mpm=prefork --with-apr=$(OPENSHIFT_DATA_DIR)/apr --with-apr-util=$(OPENSHIFT_DATA_DIR)/apu --with-pcre=$(OPENSHIFT_DATA_DIR)/pcre
httpd-2.4.6/Makefile: httpd-2.4.6/config.status
	cd httpd-2.4.6 && ./config.status
httpd/bin/apxs:  httpd-2.4.6/Makefile
	cd httpd-2.4.6 && make -s -j3 install V=0
php-5.5.5/configure: 
	curl http://us1.php.net/distributions/php-5.5.5.tar.bz2 | tar xj
php-5.5.5/config.status: httpd/bin/apxs php-5.5.5/configure
	cd php-5.5.5 && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/php --with-apxs2=$(OPENSHIFT_DATA_DIR)/httpd/bin/apxs --without-sqlite3 --without-pdo-sqlite --with-pear
php-5.5.5/Makefile: php-5.5.5/config.status
	cd php-5.5.5 && ./config.status
php/lib/libphp5.so: php-5.5.5/Makefile
	cd php-5.5.5 && make -s -j3 install V=0
