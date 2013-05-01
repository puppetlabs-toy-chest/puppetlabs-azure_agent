# == Class: azure
#
# Installs the Microsoft Azure Linux agent
#
# === Parameters
#
#      $provisioning               = 'y'
#      $delete_root_password       = 'y'
#      $regenerate_ssh_key         = 'y'
#      $ssh_key_type               = 'rsa' # Valid values are: rsa, dsa, ecdsa
#      $monitor_hostname           = 'y'
#      $resource_disk_format       = 'y'
#      $resource_disk_filesystem   = 'ext4'
#      $resource_disk_mountpoint   = '/mnt/resource'
#      $resource_disk_swap         = 'y'
#      $resource_disk_swap_size    = '4096'
#      $verbose_logs               = 'n'#
#
# === Examples
#
#  class { azure: }
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
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Service['walinuxagent'],
  }

}
