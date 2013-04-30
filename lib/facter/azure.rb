#
# Copyright (C) 2013 Panagiotis Papadomitsos
# Modified for Facter - James Turnbull
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'resolv'

# Infer the instance type from the memory available
def retrieve_instance_type
  instance_memory = (Facter.value(:memorysize).to_f)
  instance_type = if instance_memory >= 8
    'Extra Large'
  elsif instance_memory >= 4
    'Large'
  elsif instance_memory >= 2
    'Medium'
  elsif instance_memory >= 1
    'Small'
  elsif instance_memory >= 0.5
    'Extra Small'
  else
    'Unknown'
  end
  instance_type
end

# Extract information from resolv.conf
# TODO: Fix this so it supports custom DNS declared on virtual networks
def retrieve_resolv_data
  resolv_data = ::File.read(::File.expand_path(::File.join('etc', 'resolv.conf'),'/')).
    split("\n").
    grep(/^search.*cloudapp.net$/).
    first.
    split.
    fetch(1).
    split('.') || nil rescue nil
  return nil if ((! resolv_data) || (! resolv_data[0]) || (! resolv_data[1]) || (! resolv_data[3]))
  {
    :deployment_id => resolv_data[0],
    :public_hostname => "#{resolv_data[1]}.cloudapp.net",
    :location => resolv_data[3]
  }
end

def retrieve_waagent_data
  # Parse the waagent.conf file in order to retrieve resource disk info
  waagent_hash = {}
  ::File.read(::File.expand_path(::File.join('etc', 'waagent.conf'),'/')).
    split("\n").
    map{ |line| if line.match(/^\s*#/) || line.strip.empty? then next else line end }.
    compact.
    map{ |line| line.split.first }.
    each{ |line| kv = line.split('='); waagent_hash[kv.shift] = kv.shift } || nil rescue nil
  return nil if ((! waagent_hash) || (waagent_hash.empty?))
  # The resource disk is always mounted on /dev/sdb1, IF mounted
  {
      :device        => '/dev/sdb1',
      :mount         => waagent_hash['ResourceDisk.Format'].eql?('y'),
      :filesystem    => waagent_hash['ResourceDisk.Filesystem'],
      :mountpoint    => waagent_hash['ResourceDisk.MountPoint'],
      :swap_enabled  => waagent_hash['ResourceDisk.EnableSwap'].eql?('y'),
      :swap_size     => waagent_hash['ResourceDisk.SwapSizeMB'].to_i
  }
end

# Use the local resolver to resolve the hostname inferred from the search directive on resolv.conf
# Explicitly define the resolver we want to use because if we have defined our hostname in /etc/hosts
# then the class will use that and this may resolve in our local IP address
def retrieve_public_ipv4(public_hostname)
  ns = ::File.read(::File.expand_path(::File.join('etc', 'resolv.conf'),'/')).
    split("\n").
    grep(/^\s*nameserver/).
    first.
    split.
    fetch(1) || nil
  return nil unless ns
  resolver = Resolv::DNS.new(:nameserver => ns)
  resolver.getaddress(public_hostname).to_s
rescue
  nil
end

def prettify_location(location)
  location_pretty = {
    :asiaeast       => 'East Asia',
    :asiasoutheast  => 'Southeast Asia',
    :europewest     => 'West Europe',
    :europenorth    => 'North Europe',
    :useast         => 'East US',
    :uswest         => 'West US'
  }
  location_pretty[location.to_sym] || 'Unknown'
end

# Standard RPMs/DEBs use /etc/waagent.conf for configuration
def waagent_exists?
  ::File.exists?(::File.expand_path(::File.join('etc', 'waagent.conf'),'/')) &&
    `which waagent`
end

def looks_like_azure?
    retrieve_resolv_data && waagent_exists?
end

if Facter.value(:kernel) == "Linux"
  if looks_like_azure?
    Facter.debug "looks_like_azure? = true"

    Facter.add(:azure) { setcode { true } }

    resolv_data = retrieve_resolv_data

    Facter.add(:azure_public_ipv4) do
      setcode do
        retrieve_public_ipv4(resolv_data[:public_hostname])
      end
    end

    Facter.add(:azure_local_hostname) { setcode { Facter.value(:fqdn) } }
    Facter.add(:azure_local_ipv4) { setcode { Facter.value(:ipaddress) } }
    Facter.add(:azure_instance_type) { setcode { retrieve_instance_type } }

    resource_disk = retrieve_waagent_data
    resource_disk.each { |key,value|
      Facter.add("azure_resourcedisk_#{key}") { setcode { value } }
    }

    resolv_data.each { |key, value|
      Facter.add("azure_#{key}") { setcode { value } }
    }

    Facter.add(:azure_location_pretty) { setcode { prettify_location(Facter.value(:azure_location)) } }

  else
    Facter.debug "looks_like_azure? == false"
    false
  end
end
