cookbook_name = 'pipeline'

# use example chef-repo and poll master branch every minute by default
# default['pipeline']['chef-repo']['url'] = 'https://github.com/stephenlauck/pipeline-example-chef-repo.git'
default[cookbook_name]['chef-repo']['url'] = 'https://github.com/kgbconcepts/pipeline-example-chef-repo.git'
default[cookbook_name]['chef-repo']['branch'] = '*/master'
default[cookbook_name]['chef-repo']['polling'] = '* * * * *'
