jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# add proxy for jenkins
template node[jenkins_cb_name]['master']['home'] + '/proxy.xml' do
  source 'proxy.xml.erb'
  owner node[jenkins_cb_name]['master']['user']
  group node[jenkins_cb_name]['master']['group']
  mode '0644'
  variables(
    proxy: node['aw-pipeline']['proxy']['https'],
    port: node['aw-pipeline']['proxy']['port']
  )
  notifies :execute, 'jenkins_command[safe-restart]', :immediately
end
