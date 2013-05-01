require 'spec_helper'

describe 'azure', :type => 'class' do

 context 'setting all params' do
    let(:params) { {
      :provisioning               => 'y',
      :delete_root_password       => 'y',
      :regenerate_ssh_key         => 'y',
      :ssh_key_type               => 'rsa',
      :monitor_hostname           => 'y',
      :resource_disk_format       => 'y',
      :resource_disk_filesystem   => 'ext4',
      :resource_disk_mountpoint   => '/mnt/resource',
      :resource_disk_swap         => 'y',
      :resource_disk_swap_size    => '4096',
      :verbose_logs               => 'n'
    } }

    it { should contain_class 'azure' }
    it { should contain_package('walinuxagent').with_ensure('present') }
    it { should contain_file('/etc/waagent.conf').with_require('Package[walinuxagent]').with(
      'ensure'      => 'present',
      'owner'       => 'root',
      'group'       => 'root',
      'mode'        => '0644'
    ) }
    it { should contain_service('walinuxagent').with(
      'ensure'      => 'running',
      'enable'      => true,
      'hasrestart'  => true
    ) }
  end
end
