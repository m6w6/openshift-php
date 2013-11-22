PCRE_VERSION   = 8.33
APR_VERSION    = 1.5.0
APU_VERSION    = 1.5.3
APACHE_VERSION = 2.4.6
PHP_VERSION    = 5.5.6

all: httpd/modules/libphp5.so
.PHONY: all

pcre-$(PCRE_VERSION)/configure:
	curl http://softlayer-dal.dl.sourceforge.net/project/pcre/pcre/$(PCRE_VERSION)/pcre-$(PCRE_VERSION).tar.bz2 | tar xj
pcre-$(PCRE_VERSION)/config.status: pcre-$(PCRE_VERSION)/configure
	cd pcre-$(PCRE_VERSION) && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/pcre --disable-cpp --enable-unicode-properties
pcre-$(PCRE_VERSION)/Makefile: pcre-$(PCRE_VERSION)/config.status
	cd pcre-$(PCRE_VERSION) && ./config.status -q
pcre-$(PCRE_VERSION)/.libs/libpcre.so: pcre-$(PCRE_VERSION)/Makefile
	cd pcre-$(PCRE_VERSION) && make -s -j3 V=0 || make
pcre/lib/libpcre.so: pcre-$(PCRE_VERSION)/.libs/libpcre.so
	cd pcre-$(PCRE_VERSION) && make -s install V=0

apr-$(APR_VERSION)/configure:
	curl http://tweedo.com/mirror/apache//apr/apr-$(APR_VERSION).tar.bz2 | tar xj
apr-$(APR_VERSION)/config.status: apr-$(APR_VERSION)/configure
	cd apr-$(APR_VERSION) && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/apr --enable-nonportable-atomics
apr-$(APR_VERSION)/Makefile: apr-$(APR_VERSION)/config.status
	cd apr-$(APR_VERSION) && ./config.status -q
apr-$(APR_VERSION)/.libs/libapr-1.so: apr-$(APR_VERSION)/Makefile
	cd apr-$(APR_VERSION) && make -s -j3 V=0 || make
apr/lib/libapr-1.so: apr-$(APR_VERSION)/.libs/libapr-1.so
	cd apr-$(APR_VERSION) && make -s install V=0

apr-util-$(APU_VERSION)/configure:
	curl http://tweedo.com/mirror/apache//apr/apr-util-$(APU_VERSION).tar.bz2 | tar xj
apr-util-$(APU_VERSION)/config.status: apr-util-$(APU_VERSION)/configure apr/lib/libapr-1.so
	cd apr-util-$(APU_VERSION) && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/apu --with-apr=$(OPENSHIFT_DATA_DIR)/apr
apr-util-$(APU_VERSION)/Makefile: apr-util-$(APU_VERSION)/config.status
	cd apr-util-$(APU_VERSION) && ./config.status -q
apr-util-$(APU_VERSION)/.libs/libaprutil-1.so: apr-util-$(APU_VERSION)/Makefile
	cd apr-util-$(APU_VERSION) && make -s -j3 V=0 || make
apu/lib/libaprutil-1.so: apr-util-$(APU_VERSION)/.libs/libaprutil-1.so
	cd apr-util-$(APU_VERSION) && make -s install V=0

httpd-$(APACHE_VERSION)/configure:
	curl http://tweedo.com/mirror/apache//httpd/httpd-$(APACHE_VERSION).tar.bz2 | tar xj
httpd-$(APACHE_VERSION)/config.status: pcre/lib/libpcre.so apu/lib/libaprutil-1.so apr/lib/libapr-1.so httpd-$(APACHE_VERSION)/configure
	cd httpd-$(APACHE_VERSION) &&  ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/httpd --enable-so --enable-http --enable-rewrite --with-mpm=prefork --with-apr=$(OPENSHIFT_DATA_DIR)/apr --with-apr-util=$(OPENSHIFT_DATA_DIR)/apu --with-pcre=$(OPENSHIFT_DATA_DIR)/pcre
httpd-$(APACHE_VERSION)/Makefile: httpd-$(APACHE_VERSION)/config.status
	cd httpd-$(APACHE_VERSION) && ./config.status -q
httpd-$(APACHE_VERSION)/support/apxs: httpd-$(APACHE_VERSION)/Makefile
	cd httpd-$(APACHE_VERSION) && make -s -j3 V=0 || make
httpd/bin/apxs:  httpd-$(APACHE_VERSION)/support/apxs
	cd httpd-$(APACHE_VERSION) && make -s install V=0

php-$(PHP_VERSION)/configure:
	curl http://us1.php.net/distributions/php-$(PHP_VERSION).tar.bz2 | tar xj
php-$(PHP_VERSION)/config.status: httpd/bin/apxs php-$(PHP_VERSION)/configure
	cd php-$(PHP_VERSION) && ./configure -C --prefix=$(OPENSHIFT_DATA_DIR)/php --with-apxs2=$(OPENSHIFT_DATA_DIR)/httpd/bin/apxs --without-sqlite3 --without-pdo-sqlite --with-pear
php-$(PHP_VERSION)/Makefile: php-$(PHP_VERSION)/config.status
	cd php-$(PHP_VERSION) && ./config.status -q
php-$(PHP_VERSION)/.libs/libphp5.so: php-$(PHP_VERSION)/Makefile
	cd php-$(PHP_VERSION) && make -s -j3 V=0 || make
httpd/modules/libphp5.so: php-$(PHP_VERSION)/.libs/libphp5.so
	cd php-$(PHP_VERSION) && make -s install V=0
