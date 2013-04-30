# == Class: azure
#
# Full description of class azure here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { azure:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# James Turnbull <james@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs, Inc
#
class azure(
  $provisioning               = 'y',
  $delete_root_password       = 'y',
  $regenerate_ssh_key         = 'y',
  $ssh_key_type               = 'rsa', # Valid values are: rsa, dsa, ecdsa
  $monitor_hostname           = 'y',
  $resource_disk_format       = 'y',
  $resource_disk_filesystem   = 'ext4',
  $resource_disk_mountpoint   = '/mnt/resource',
  $resource_disk_swap         = 'y',
  $resource_disk_swap_size    = '4096',
  $verbose_logs               = 'n'
  ) {

  package { 'walinuxagent':
    ensure => present,
  }

  file { '/etc/waagent.conf':
    ensure  => present,
    content => template('azure/waagent.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['walinuxagent'],
    notify  => Service['walinuxagent'],
  }

  service { 'walinuxagent':
    ensure  => started,
    enable  => true,
    require => Service['walinuxagent'],
  }

}
