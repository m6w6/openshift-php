PHPINI   = ./php/lib/php.ini
PECLCMD  = ./php/bin/pecl -c .pearrc
PEARCMD  = ./php/bin/pear -c .pearrc
CURRENT  = $(OPENSHIFT_DEPLOYMENTS_DIR)/current/repo/
EXTDIR   = $(shell ./php/bin/php-config --extension-dir)
EXTNAMES = $(shell $(CURRENT)/.openshift/dep.awk < $(CURRENT)/.openshift/pecl.dep | cut -f1)
VERSIONS = $(shell $(CURRENT)/.openshift/dep.awk < $(CURRENT)/.openshift/pecl.dep | cut -f2)
LIBNAMES = $(shell $(CURRENT)/.openshift/dep.awk < $(CURRENT)/.openshift/pecl.dep | cut -f3)
EXTFILES = $(addsuffix .so, $(addprefix $(EXTDIR)/, $(LIBNAMES)))
PROJECTS = $(wildcard $(CURRENT)/*/openshift.mk)

export

all: ini $(EXTFILES) httpd/conf/httpd.conf mk-projects
	for ext in $(LIBNAMES); do grep -Eq "^[[:space:]]*extension[[:space:]]*=[[:space:]]*$$ext.so" $(PHPINI) || echo "extension=$$ext.so" >> $(PHPINI); done

.PHONY: ini all mk-projects

mk-projects:
	$(foreach project, $(PROJECTS), cd $(dir $(project)) && $(MAKE) -f openshift.mk)

$(CURRENT)/public:
	mkdir -p $@

ini: $(PHPINI)
	$(PECLCMD) config-set php_ini $(OPENSHIFT_DATA_DIR)/$(PHPINI)
	$(PEARCMD) config-set php_ini $(OPENSHIFT_DATA_DIR)/$(PHPINI)

$(EXTDIR)/%: httpd/modules/libphp5.so $(CURRENT)/.openshift/pecl.dep
	aE=($(EXTNAMES)); aV=($(VERSIONS)); aL=($(LIBNAMES)); \
	for ((i=0; i < $${#aE[@]}; i++)); do \
		if test $* = $(EXTDIR)/$${aL[$$i]}.so; then \
			$(PECLCMD) install $${aE[$$i]}-$${aV[$$i]} || $(PECLCMD) upgrade $${aE[$$i]}-$${aV[$$i]}; \
			./php/bin/php -m | grep -q $$aL[$$i] || $(PECLCMD) install -f $${aE[$$i]}-$${aV[$$i]}; \
		fi; \
	done

$(PHPINI): $(CURRENT)/.openshift/php.ini.in
	(echo "; generated file; do not edit"; envsubst < $^) > $@
httpd/conf/httpd.conf: $(CURRENT)/.openshift/httpd.conf.in | $(CURRENT)/public
	(echo "# generated file; do not edit"; envsubst < $^) > $@
