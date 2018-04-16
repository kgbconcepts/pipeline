cookbook_name = 'pipeline'

# non-pipelined berks group for community cookbook install/upload
default[cookbook_name]['berkshelf']['external']['group'] = 'community'

default[cookbook_name]['chef_client_cmd'] = '/usr/bin/chef-client'
