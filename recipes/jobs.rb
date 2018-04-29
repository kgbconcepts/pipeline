cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# set up chef-repo job per chef-repo
chef_repos.each do |repo|
  create_jenkins_job(
    repo['name'],
    repo['url'],
    node[jenkins_cb_name]['git_plugin_version'],
    node[cookbook_name]['chef-repo']['branch'],
    node[cookbook_name]['chef-repo']['polling'],
    '_knife_commands.sh.erb',
    node[cookbook_name]['berkshelf']['external']['group'],
    node[cookbook_name]['chef_client_cmd'],
    node[cookbook_name]['template']['cookbook']
  )
  cookbooks_in_berksfile_of_repo(repo['name']).each do |cookbook|
    Chef::Log.info cookbook.location.to_s
    create_jenkins_job(
      cookbook.name,
      cookbook.location.uri,
      node[jenkins_cb_name]['git_plugin_version'],
      node[cookbook_name]['chef-repo']['branch'],
      node[cookbook_name]['chef-repo']['polling'],
      '_cookbook_command.sh.erb',
      node[cookbook_name]['berkshelf']['external']['group'],
      node[cookbook_name]['chef_client_cmd'],
      node[cookbook_name]['template']['cookbook']
    )
  end
end

# turn off cli at the end
node.override[cookbook_name]['enable_cli'] = 'false'

template 'jenkins_groovy_init_7' do
  source '7_disable_cli.groovy.erb'
  path node[jenkins_cb_name]['master']['home'] + '/init.groovy.d/7_disable_cli.groovy'
  variables(
    enable_cli: node[cookbook_name]['enable_cli']
  )
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0640'
  # notifies :restart, 'service[jenkins]', :delayed
  action :nothing
end
