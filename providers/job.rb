action :create do
  xml = Chef::Config[:file_cache_path] + '/' + new_resource.job_name + '.xml'

  template xml do
    source new_resource.job_name + '.xml.erb'
    variables(
      git_url: new_resource.git_url,
      git_ver: new_resource.git_ver,
      build_command: new_resource.build_command
    )
  end

  jenkins_job new_resource.job_name do
    config xml
  end
end
