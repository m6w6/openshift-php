# Openshift PHP

Build and setup Apache-2.4 and PHP-5.5 on RedHat's Openshift PaaS

## How to start:

### As merged subtree

```
$ git remote add openshift-php https://github.com/m6w6/openshift-php.git
$ git fetch openshift-php
$ git read-tree --prefix=.openshift/ -u openshift-php/master
```

### As submodule

```
$ git submodule add git://github.com/m6w6/openshift-php.git .openshift
```


