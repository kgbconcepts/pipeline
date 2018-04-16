#
# Cookbook Name:: pipeline
# Recipe:: jenkins
#
# Copyright 2014, Stephen Lauck <lauck@getchef.com>
# Copyright 2014, Chef, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

include_recipe 'java'
include_recipe 'jenkins::master'
include_recipe 'git'

package 'unzip' do
  action :install
end

sudo node[jenkins_cb_name]['master']['user'] do
  user node[jenkins_cb_name]['master']['user']
  nopasswd true
  commands [node[cookbook_name]['chef_client_cmd']]
end

execute 'install_gradle' do
  command <<-EOH.gsub(/^ {4}/, '')
    cd /tmp
    curl -L -Of https://services.gradle.org/distributions/gradle-4.6-bin.zip
    unzip -oq gradle-4.6-bin.zip -d /opt/
    ln -s /opt/gradle-4.6 /opt/gradle
    chmod -R +x /opt/gradle/lib/
    printf "export GRADLE_HOME=/opt/gradle\nexport PATH=\$PATH:/opt/gradle/bin" > /etc/profile.d/gradle.sh
    . /etc/profile.d/gradle.sh
    # check installation
    gradle -v
  EOH
  not_if { ::File.exist?('/opt/gradle/bin/gradle') }
end
# Sets up Authentication for Chef-Client towards Jenkins
# This is one possbile implementation for handling this.
# For more details, see the Jenkins cookbook documentation.
# Nothing will be done, if your wrapper cookbook already defined
# node.run_state[:jenkins_private_key]

require 'openssl'
require 'net/ssh'

chef_orgs.each do |org|
  jenkins_key = org['pem']

  key = OpenSSL::PKey::RSA.new(jenkins_key)
  private_key = key.to_pem
  public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

  # Create the Jenkins user with the public key
  jenkins_user org['client'] do
    id org['client']
    full_name 'temp Client'
    email org['client'] + '@domain.local'
    password org['password']
    public_keys [public_key]
  end

  # Set the private key on the Jenkins executor
  unless node.run_state[:jenkins_private_key]
    node.run_state[:jenkins_private_key] = private_key
  end
end

# Turn on basic authentication
jenkins_script 'setup authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    def instance = Jenkins.getInstance()
    import hudson.security.*
    def realm = new HudsonPrivateSecurityRealm(false)
    instance.setSecurityRealm(realm)
    def strategy = new #{node[cookbook_name]['AuthorizationStrategy']}()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
  EOH
end

# https://wiki.jenkins-ci.org/display/JENKINS/Post-initialization+script
directory node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/' do
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0755'
  recursive true
end

template node[jenkins_cb_name]['master']['home'] + '/build.gradle' do
  source 'jenkins_home_build_gradle.erb'
  variables(
    plugins: node[cookbook_name]['plugins'].sort.to_h
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
end

execute 'install_plugins' do
  command <<-EOH.gsub(/^ {4}/, '')
    source /etc/profile
    /opt/gradle/bin/gradle install && /opt/gradle/bin/gradle dependencies > 'plugins.lock'
  EOH
  user node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  cwd node[jenkins_cb_name]['master']['home']
end

# we need to ensure that all the newly downloaded plugins are registered
jenkins_command 'safe-restart'
