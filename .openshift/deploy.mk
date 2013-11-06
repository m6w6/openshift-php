PECLCMD = ./php/bin/pecl -c .pearrc
PHPEXTS = $(shell ./php/bin/php-config --extension-dir)
CURRENT = $(OPENSHIFT_DEPLOYMENTS_DIR)/current/repo/

all: ini httpd/logs/httpd.pid
.PHONY: ini all

ini:
	$(PECLCMD) config-set php_ini $(OPENSHIFT_DATA_DIR)/php/lib/php.ini

$(PHPEXTS)/raphf.so: httpd/modules/libphp5.so
	$(PECLCMD) install -f raphf
$(PHPEXTS)/propro.so: httpd/modules/libphp5.so
	$(PECLCMD) install -f propro
$(PHPEXTS)/http.so: $(PHPEXTS)/raphf.so $(PHPEXTS)/propro.so
	$(PECLCMD) install -f pecl_http
php/lib/php.ini: $(CURRENT)/.openshift/php.ini.in
	(echo "; generated file; do not edit"; envsubst < $^) > $@
httpd/conf/httpd.conf: $(CURRENT)/.openshift/httpd.conf.in
	(echo "# generated file; do not edit"; envsubst < $^) > $@
httpd/logs/httpd.pid: httpd/conf/httpd.conf php/lib/php.ini
	test -f $@ && ./httpd/bin/apachectl restart
