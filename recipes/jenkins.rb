#
# Cookbook Name:: pipeline
# Recipe:: jenkins
#
# portability assignments, wrapper cookbook and jenkins wrapper cookbook
cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# set jenkins restart to false by default
jenkins_restart_required = false

# addtional packages for this to work
node[cookbook_name]['pkgs'].each do |pkgs|
  package pkgs do
    action :install
  end
end

# here are our included recipes first
include_recipe 'java'
include_recipe "#{jenkins_cb_name}::master"
# handle gradle/jenkins plugins
include_recipe "#{cookbook_name}::jenkins_plugins"
# deploy jenkins groovy init scripts
include_recipe "#{cookbook_name}::jenkins_scripts"
include_recipe 'git'

# sudo no password privileges for jenkins user and command
sudo node[jenkins_cb_name]['master']['user'] do
  user node[jenkins_cb_name]['master']['user']
  nopasswd true
  commands [node[cookbook_name]['chef_client_cmd']]
  action :create
end

# Sets up Authentication for Chef-Client towards Jenkins
# This is one possbile implementation for handling this.
# For more details, see the Jenkins cookbook documentation.
# Nothing will be done, if your wrapper cookbook already defined
# node.run_state[:jenkins_private_key]

# this is our test/local/simple style version
# need ssl/openssh ruby libraries
require 'openssl'
require 'net/ssh'

# goes through orgs in data bags
chef_orgs.each do |org|
  # use org id and get pem key
  jenkins_key = org['pem']

  # create ssl key from private pem
  key = OpenSSL::PKey::RSA.new(jenkins_key)
  # key to pem
  private_key = key.to_pem
  # create public key
  public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

  # Create the Jenkins user with the public key and passowrd from bags
  jenkins_user org['client'] do
    id org['client']
    full_name org['client']
    email org['client'] + '@domain.local'
    password org['password']
    public_keys [public_key]
    action :create
  end

  # Set the private key on the Jenkins executor
  unless node.run_state[:jenkins_private_key]
    node.run_state[:jenkins_private_key] = private_key
  end
end

# we need to ensure that all the newly downloaded plugins are registered
# Is notified only when a 'jenkins_plugin' is installed or updated.
ruby_block 'jenkins_restart_flag' do
  block do
    jenkins_restart_required = true
  end
  action :nothing
end

jenkins_command 'safe-restart' do
  only_if { jenkins_restart_required }
end
