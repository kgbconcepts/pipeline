cookbook_name = 'pipeline'

# assigns our wrapper cookbook recipe chfdk channels/release
default[cookbook_name]['chefdk']['version'] = :latest
default[cookbook_name]['chefdk']['channel'] = :stable

# assigns our wrapper cookbook recipe chfdk channels/release
# to chefdk cookbook attributes
default['chefdk']['version'] = node[cookbook_name]['chefdk']['version']
default['chefdk']['channel'] = node[cookbook_name]['chefdk']['channel']
