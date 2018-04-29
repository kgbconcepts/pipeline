#
# Cookbook Name:: pipeline
# Recipe:: jenkins_scripts
#
# portability assignments, wrapper cookbook and jenkins wrapper cookbook
cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# set jenkins restart to false by default
jenkins_restart_required = false

# https://wiki.jenkins-ci.org/display/JENKINS/Post-initialization+script
directory node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/' do
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0755'
  recursive true
  action :create
end

# enable cli for run
template 'jenkins_groovy_init_7' do
  source '7_disable_cli.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/7_disable_cli.groovy'
  variables(
    enable_cli: node[cookbook_name]['enable_cli']
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
end

# custom startups groovy
template 'jenkins_groovy_init_1' do
  source '1_users_and_setauth.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/1_users_and_setauth.groovy'
  variables(
    auth_strategy: node[cookbook_name]['AuthorizationStrategy'],
    auth_allow_anon_read: node[cookbook_name]['AuthorizationStrategyAllowAnonRead']
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
end

# custom startups groovy
template 'jenkins_groovy_init_2' do
  source '2_executors.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/2_executors.groovy'
  variables(
    executors_num: node[cookbook_name]['num_of_executors']
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
end

template 'jenkins_groovy_init_3' do
  source '3_slave_master_acl.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/3_slave_master_acl.groovy'
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
end

template 'jenkins_groovy_init_8' do
  source '8_disable_scripts_security_jobdsl.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/8_disable_scripts_security_jobdsl.groovy'
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :nothing
end

template 'jenkins_groovy_init_9' do
  source '9_enable_csrf_security.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/9_enable_csrf_security.groovy'
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
end

template 'jenkins_groovy_init_10' do
  source '10_jnlp_agent_proto.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/10_jnlp_agent_proto.groovy'
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  notifies :run, 'ruby_block[jenkins_restart_flag]', :delayed
  action :create
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
