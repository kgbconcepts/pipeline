cookbook_name = 'pipeline'

# use chef-zero url for default
default[cookbook_name]['chef_server']['url'] = 'http://localhost:80'
default[cookbook_name]['chef_server']['node_name'] = 'pipeline'
