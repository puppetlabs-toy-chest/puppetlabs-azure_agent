# == Class: azure_agent
#
# Installs the Microsoft Azure Linux agent
#
# === Parameters
#
#      $package_name               = 'WALinuxAgent'
#      $service_name               = 'waagent'
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
#  class { azure_agent: }
#
# === Authors
#
# James Turnbull <james@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs, Inc
#
class azure_agent(
  String $package_name,
  String $service_name,
  Enum['y','n'] $provisioning,
  Enum['y','n'] $delete_root_password,
  Enum['y','n'] $regenerate_ssh_key,
  Enum['rsa','dsa','ecdsa'] $ssh_key_type,
  Enum['y','n'] $monitor_hostname,
  Enum['y','n'] $resource_disk_format,
  Enum['ext3','ext4'] $resource_disk_filesystem,
  Stdlib::UnixPath $resource_disk_mountpoint,
  Enum['y','n'] $resource_disk_swap,
  Integer $resource_disk_swap_size,
  Enum['y','n'] $verbose_logs,
  ) {

  unless ("${facts['os']['family']}${facts['os']['release']['major']}" =~ /RedHat[67]/) {
    fail("Module azure_agent is not supported on ${facts['os']['family']} ${facts['os']['release']['major']}")
  }

  package { 'walinuxagent':
    ensure => present,
    name   => $package_name,
  }

  file { '/etc/waagent.conf':
    ensure  => 'file',
    content => epp('azure_agent/waagent.conf.epp', {
      'provisioning'             => $provisioning,
      'delete_root_password'     => $delete_root_password,
      'regenerate_ssh_key'       => $regenerate_ssh_key,
      'ssh_key_type'             => $ssh_key_type,
      'monitor_hostname'         => $monitor_hostname,
      'resource_disk_format'     => $resource_disk_format,
      'resource_disk_filesystem' => $resource_disk_filesystem,
      'resource_disk_mountpoint' => $resource_disk_mountpoint,
      'resource_disk_swap'       => $resource_disk_swap,
      'resource_disk_swap_size'  => $resource_disk_swap_size,
      'verbose_logs'             => $verbose_logs,
    } ),
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
    name       => $service_name,
  }
}

