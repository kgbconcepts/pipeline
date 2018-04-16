cookbook_name = 'pipeline'

default[cookbook_name]['chefdk']['version'] = :latest
default[cookbook_name]['chefdk']['channel'] = :stable
default['chefdk']['version'] = node[cookbook_name]['chefdk']['version']
default['chefdk']['channel'] = node[cookbook_name]['chefdk']['channel']
