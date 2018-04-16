#
# Cookbook Name:: pipeline
# Recipe:: default
#

cookbook_name = 'pipeline'

if node[cookbook_name]['deploy_full'] == true
  [
    # see .kitchen.yml for usage
  ].each { |recipe_name| include_recipe recipe_name }
end
