Puppet-faster-Apache
====================

Puppet script for Apache2 mod_pagespeed and mod_spdy

Use it like this: 

```
    class { 'nyholm::faster_apache::params': }
    class { 'nyholm::faster_apache::modpagespeed': }
    class { 'nyholm::faster_apache::modspdy': }
```
