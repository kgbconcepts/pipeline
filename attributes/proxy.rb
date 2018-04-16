cookbook_name = 'pipeline'

# set proxy for adding jenkins plugins
default[cookbook_name]['proxy']['https'] = 'yourproxy.com'
default[cookbook_name]['proxy']['port'] = '8080'
