# Openshift PHP

Build and setup Apache-2.4 and PHP-5.6 on RedHat's Openshift PaaS

## How to start:

### As submodule

```
$ git submodule add git://github.com/m6w6/openshift-php.git .openshift
```

### As merged subtree

```
$ git remote add openshift-php https://github.com/m6w6/openshift-php.git
$ git checkout -b openshift-php openshift-php/master
$ git checkout master
$ git read-tree --prefix=.openshift/ -u openshift-php
```

#### Updating a merged subtree

```
$ git checkout openshift-php
$ git pull
$ git checkout master
$ git merge -s recursive -X subtree=.openshift openshift-php
```


