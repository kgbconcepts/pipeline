#
# Cookbook Name:: pipeline
# Recipe:: jenkins_scripts
#
# portability assignments, wrapper cookbook and jenkins wrapper cookbook
cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']
include_recipe 'gradle'

# set jenkins restart to false by default
jenkins_restart_required = false

# deploy gradle build script template
template 'template_build_gradle' do
  path node[jenkins_cb_name]['master']['home'] + '/build.gradle'
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
    #!/bin/bash
    gradle install && gradle dependencies > 'plugins.lock'
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
