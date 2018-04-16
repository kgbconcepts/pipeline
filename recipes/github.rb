# github related repo work/fixes
# assign jenkins cookbook var for portability
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

# override fingerprint rsa
file node[jenkins_cb_name]['server']['home'] + '/.ssh/config' do
  content <<-EOD
   Host github.com
       StrictHostKeyChecking no
  EOD
  owner node[jenkins_cb_name]['server']['user']
  group node[jenkins_cb_name]['server']['user']
end
