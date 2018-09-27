# Puppet Labs Azure Agent

This module was formerly the puppetlabs-azure module. [Moved at version 0.0.3]

This is the Puppet Labs Azure Agent module. The Azure module installs and
configures the Microsoft Azure Linux agent.

It assumes you have the Windows Azure Linux package, `walinuxagent`,
available in a local repository to be installed.

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-azure_agent.png)](https://travis-ci.org/puppetlabs/puppetlabs-azure_agent)

Usage
-----

Add the class to the required nodes, using the default options:

    class {'azure': }

Configurable options (with their defaults) are:

    $provisioning               = 'y'
    $delete_root_password       = 'y'
    $regenerate_ssh_key         = 'y'
    $ssh_key_type               = 'rsa' # Valid values are: rsa, dsa, ecdsa
    $monitor_hostname           = 'y'
    $resource_disk_format       = 'y'
    $resource_disk_filesystem   = 'ext4'
    $resource_disk_mountpoint   = '/mnt/resource'
    $resource_disk_swap         = 'y'
    $resource_disk_swap_size    = 4096
    $verbose_logs               = 'n'

The module also adds some Azure facts. The code for which is modified
from work by Panagiotis Papadomitsos.

The following facts should be available:

    azure => true
    azure_deployment_id => 9f108ac9fd3a4a6bb400b2867a11d0e2
    azure_instance_type => Extra Large
    azure_local_hostname => absinthe.local
    azure_local_ipv4 => 10.7.1.143
    azure_location => europewest
    azure_location_pretty => West Europe
    azure_public_hostname => testruby.cloudapp.net
    azure_public_ipv4 => 192.1.2.1
    azure_resourcedisk_device => /dev/sdb1
    azure_resourcedisk_filesystem => "/dev/sbd"
    azure_resourcedisk_mount => false
    azure_resourcedisk_mountpoint => "/dev/test"
    azure_resourcedisk_swap_enabled => true
    azure_resourcedisk_swap_size => 80

License
-------

Apache 2.0

Contact
-------

James Turnbull <james@puppetlabs.com>

Support
-------

Please log tickets and issues
[here](https://github.com/puppetlabs/puppetlabs-azure_agent/issues).
