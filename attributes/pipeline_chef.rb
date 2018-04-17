cookbook_name = 'pipeline'

# non-pipelined berks group for community cookbook install/upload
default[cookbook_name]['berkshelf']['external']['group'] = 'community'

# setup chef client command run for chef pipeline
# if it has the cookbook_name::cookbook_name_test its kitchen
default[cookbook_name]['chef_client_cmd'] =
  if node.recipe?("#{cookbook_name}::#{cookbook_name}_test")
    '/usr/bin/chef-client -z -c /tmp/kitchen/client.rb'
  else
    '/usr/bin/chef-client'
  end
