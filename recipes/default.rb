#
# Cookbook Name:: sogo
# Recipe:: default
#
# Copyright 2014, OpenSinergia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Resource::Template.send(:include, Sogo::Helper)
::Chef::Resource::RubyBlock.send(:include, Sogo::Helper)

include_recipe "apt"
include_recipe "base-debian-ubuntu::usefulcommands"

apt_repository 'sogo' do
  # deb http://inverse.ca/ubuntu precise precise
  # deb http://inverse.ca/debian wheezy wheezy
  uri          "http://inverse.ca/" + node['lsb']['id'].downcase
  distribution node['lsb']['codename']
  components   [node['lsb']['codename']]
  keyserver    'keys.gnupg.net'
  key          '810273C4'
  notifies :run, "execute[force-apt-get-update-execution]", :immediately
end

package 'sogo'

config_base_json = Chef::Config[:file_cache_path] + "/" + "sogo_base_config" + ".json"
template config_base_json do
  source 'sogo_base_config.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    :db_user => node['sogo']['db_user'],
    :db_password => node['sogo']['db_password'],
    :db_host => node['sogo']['db_host'],
    :db_name => node['sogo']['db_name'],
    :imap_server => node['sogo']['imap_server'],
    :smtp_server => node['sogo']['smtp_server']
  })
end

ruby_block 'generate-sogo-config-file' do
  block do
    require 'fileutils'
    config_file = '/etc/sogo/sogo.conf'
    base_config = File.read(config_base_json)
    specific_config = node['sogo']['specific_config_json']
    plist = generate_plist(merge_json_to_hash(base_config, specific_config))
    File.open(config_file, 'w') {|f|
      f << "{\n"
      plist.each {|l|
        f << l + "\n"
      }
      f << "}"
    }
    FileUtils.chown('root', 'sogo', config_file)
    FileUtils.chmod(0640, config_file)
  end
end

if node['sogo']['use_vhost'] == true
  # apache virtual host 
  web_app node['sogo']['web_app_name'] do
    server_name node['sogo']['web_app_dns_name']
    #docroot ???
    template "SOGo_apache_vhost.conf.erb"
    log_dir node['apache']['log_dir']
  end
else
  # location within a virtual host
  template '/etc/apache2/conf.d/SOGo.conf' do
    source 'SOGo_apache_location.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables({
      :server_name => node['sogo']['web_app_dns_name'],
      :server_url => 'http://' + node['sogo']['web_app_dns_name']
    })
  end
end

include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_rewrite"

# needed for SOGo, just to read the new configuration
service 'sogo' do
  action [:enable, :restart]
end
