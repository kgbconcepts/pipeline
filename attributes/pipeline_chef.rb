cookbook_name = 'pipeline'

# non-pipelined berks group for community cookbook install/upload
default[cookbook_name]['berkshelf']['external']['group'] = 'community'

# setup chef client command run for chef pipeline
default[cookbook_name]['chef_client_cmd'] = '/usr/bin/chef-client'
