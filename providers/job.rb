action :create do
  xml = Chef::Config[:file_cache_path] + '/' + new_resource.job_name + '.xml'

  template xml do
    source new_resource.job_name + '.xml.erb'
    variables(
      git_url: new_resource.git_url,
      git_ver: new_resource.git_ver,
      branch: new_resource.branch,
      polling: new_resource.polling,
      build_command: new_resource.build_command,
      build_command_var1: new_resource.build_command_var1,
      build_command_var2: new_resource.build_command_var2,
      cookbook: new_resource.cookbook
    )
  end

  jenkins_job new_resource.job_name do
    config xml
  end
end
