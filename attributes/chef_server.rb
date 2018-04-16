cookbook_name = 'pipeline'

# use chef-zero url for default
default[cookbook_name]['chef_server']['url'] = 'http://0.0.0.0:80'
default[cookbook_name]['chef_server']['node_name'] = 'pipeline'
