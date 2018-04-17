cookbook_name = 'pipeline'

default[cookbook_name]['jenkins_cb_name'] = 'jenkins'
jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']

default[jenkins_cb_name]['git_plugin_version'] = '3.8.0'
# default['jenkins']['master']['mirror'] = 'http://updates.jenkins.io'
# default['jenkins']['master']['mirror'] = 'http://updates.jenkins-ci.org'
default[jenkins_cb_name]['executor']['protocol'] = 'remoting' # default remoting
# executor['cli_user'] = 'example_chef_user'
# default['jenkins']['executor']['cli_user'] = 'example_chef_user'
default[jenkins_cb_name]['executor']['cli_user'] = 'pipeline'
# default[jenkins_cb_name]['master']['home'] = '/opt/jenkins'

# eg: 'FullControlOnceLoggedInAuthorizationStrategy'
default[cookbook_name]['AuthorizationStrategy'] = 'FullControlOnceLoggedInAuthorizationStrategy'

default[cookbook_name].tap do |jenkins_wrapper|
  jenkins_wrapper['plugins'] = {
    'command-launcher' => {
      'version' => '1.2',
    },
    'bouncycastle-api' => {
      'version' => '2.16.2',
    },
    'script-security' => {
      'version' => '1.43',
    },
    'structs' => {
      'version' => '1.14',
    },
    'display-url-api' => {
      'version' => '2.2.0',
    },
    'mailer' => {
      'version' => '1.21',
    },
    'token-macro' => {
      'version' => '2.5',
    },
    'credentials' => {
      'version' => '2.1.16',
    },
    'ssh-credentials' => {
      'version' => '1.13',
    },
    'scm-api' => {
      'version' => '2.2.6',
    },
    'workflow-step-api' => {
      'version' => '2.14',
      'group' => 'org.jenkins-ci.plugins.workflow',
    },
    'workflow-api' => {
      'version' => '2.27',
      'group' => 'org.jenkins-ci.plugins.workflow',
    },
    'junit' => {
      'version' => '1.24',
    },
    'matrix-project' => {
      'version' => '1.13',
    },
    'git-client' => {
      'version' => '2.7.1',
    },
    'workflow-scm-step' => {
      'version' => '2.6',
      'group' => 'org.jenkins-ci.plugins.workflow',
    },
    'git' => {
      'version' => node[jenkins_cb_name]['git_plugin_version'],
    },
    'chef-identity' => {
      'version' => '1.0.0',
    },
  }
end
