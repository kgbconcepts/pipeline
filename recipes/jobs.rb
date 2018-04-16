cookbook_name = 'pipeline'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# set up chef-repo job per chef-repo
chef_repos.each do |repo|
  create_jenkins_job(
    repo['name'],
    repo['url'],
    node[jenkins_cb_name]['git_plugin_version'],
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
      '_cookbook_command.sh.erb',
      node[cookbook_name]['template']['cookbook']
    )
  end
end
