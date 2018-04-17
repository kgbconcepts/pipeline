#
# Cookbook Name:: pipeline
# Recipe:: jenkins
#
# portability assignments, wrapper cookbook and jenkins wrapper cookbook
cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# set jenkins restart to false
jenkins_restart_required = false

# here are our included recipes first
include_recipe 'java'
include_recipe "#{jenkins_cb_name}::master"
include_recipe 'git'

# addtional packages for this to work
node[cookbook_name]['pkgs'].each do |pkgs|
  package pkgs do
    action :install
  end
end

# sudo no password privileges for jenkins user and command
sudo node[jenkins_cb_name]['master']['user'] do
  user node[jenkins_cb_name]['master']['user']
  nopasswd true
  commands [node[cookbook_name]['chef_client_cmd']]
  action :create
end

# cli download and deploy gradle for jenkins plugins management
execute 'install_gradle' do
  command <<-EOH.gsub(/^ {4}/, '')
    cd /tmp
    curl -L -Of https://services.gradle.org/distributions/gradle-#{node[cookbook_name]['gradle_ver']}-bin.zip
    unzip -oq gradle-#{node[cookbook_name]['gradle_ver']}-bin.zip -d /opt/
    ln -s /opt/gradle-#{node[cookbook_name]['gradle_ver']} /opt/gradle
    chmod -R +x /opt/gradle/lib/
    printf "export GRADLE_HOME=/opt/gradle\nexport PATH=\$PATH:/opt/gradle/bin" > /etc/profile.d/gradle.sh
    . /etc/profile.d/gradle.sh
    # check installation
    gradle -v
  EOH
  action :run
  not_if { ::File.exist?('/opt/gradle/bin/gradle') }
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

# Turn on basic authentication
jenkins_script 'setup authentication' do
  command <<-EOH.gsub(/^ {4}/, '')
    import jenkins.model.*
    import hudson.security.*
    import hudson.security.csrf.DefaultCrumbIssuer

    def instance = Jenkins.getInstance()
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)

    instance.setSecurityRealm(hudsonRealm)
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))

    def strategy = new #{node[cookbook_name]['AuthorizationStrategy']}()
    strategy.setAllowAnonymousRead(false)
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
  action :create
end

# deploy gradle build script template
template node[jenkins_cb_name]['master']['home'] + '/build.gradle' do
  source 'jenkins_home_build_gradle.erb'
  variables(
    plugins: node[cookbook_name]['plugins'].sort.to_h
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'execute[install_plugins]', :immediately
  action :create
end

# install and manage plugins from here,
# set to install and generate a lock file
execute 'install_plugins' do
  command <<-EOH.gsub(/^ {4}/, '')
    source /etc/profile
    /opt/gradle/bin/gradle install && /opt/gradle/bin/gradle dependencies > 'plugins.lock'
  EOH
  user node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  cwd node[jenkins_cb_name]['master']['home']
  notifies :run, 'ruby_block[jenkins_restart_flag]', :immediately
  action :nothing
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
