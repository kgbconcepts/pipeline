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
  jenkins_job repo['name'] do
    # if true will live stream the console output of the executing job  (default is true)
    stream_job_output true
    # if true will block the Chef client run until the build is completed or aborted (defaults to true)
    wait_for_completion false
    subscribes :build, "create_jenkins_job[#{repo['name']}]", :immediately
    action :nothing
  end
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
