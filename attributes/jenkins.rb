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
      'version' => '1.2'
    },
    'bouncycastle-api' => {
      'version' => '2.16.2'
    },
    'script-security' => {
      'version' => '1.43'
    },
    'structs' => {
      'version' => '1.14'
    },
    'display-url-api' => {
      'version' => '2.2.0'
    },
    'mailer' => {
      'version' => '1.21'
    },
    'token-macro' => {
      'version' => '2.5'
    },
    'credentials' => {
      'version' => '2.1.16'
    },
    'ssh-credentials' => {
      'version' => '1.13'
    },
    'scm-api' => {
      'version' => '2.2.6'
    },
    'workflow-step-api' => {
      'version' => '2.14',
      'group' => 'org.jenkins-ci.plugins.workflow'
    },
    'workflow-api' => {
      'version' => '2.27',
      'group' => 'org.jenkins-ci.plugins.workflow'
    },
    'junit' => {
      'version' => '1.24'
    },
    'matrix-project' => {
      'version' => '1.13'
    },
    'git-client' => {
      'version' => '2.7.1'
    },
    'workflow-scm-step' => {
      'version' => '2.6',
      'group' => 'org.jenkins-ci.plugins.workflow'
    },
    'git' => {
      'version' => node[jenkins_cb_name]['git_plugin_version']
    },
    'chef-identity' => {
      'version' => '1.0.0'
    }
  }
end

# default['pipeline']['jenkins']['plugins'] = [
#   'jsch=0.1.54.2',
#   'apache-httpcomponents-client-4-api=4.5.3-2.1',
#   'mapdb-api=1.0.9.0',
#   'subversion=2.10.5',
#   'javadoc=1.4',
#   'maven-plugin=3.1.2',
#   'cloudbees-folder=6.4',
#   'matrix-auth=2.2',
#   'external-monitor-job=1.7',
#   'ldap=1.20',
#   'pam-auth=1.3',
#   'ant=1.8',
#   'windows-slaves=1.3.1',
#   'antisamy-markup-formatter=1.5',
#   'run-condition=1.0',
#   'conditional-buildstep=1.3.6',
#   'config-file-provider=2.18',
#   'rebuild=1.28',
#   'project-inheritance=2.0.0',
#   'managed-scripts=1.4',
#   'job-dsl=1.68',
#   'promoted-builds=3.1',
#   'parameterized-trigger=2.35.2',
#   'git=3.8.0',
#   'plain-credentials=1.4',
#   'jackson2-api=2.8.11.1',
#   'github-api=1.90',
#   'github=1.29.0',
#   'branch-api=2.0.19',
#   'workflow-support=2.18',
#   'workflow-job=2.18',
#   'jquery-detached=1.2.1',
#   'ace-editor=1.1',
#   'support-core=2.46',
#   'workflow-cps=2.47',
#   'scm-api=2.2.6',
#   'workflow-multibranch=2.17',
#   'github-branch-source=2.3.3',
#   'github-oauth=0.29',
#   'packer=1.5',
#   'terraform=1.0.9',
# ]

#   'jsch=0.1.54.2',
#   'apache-httpcomponents-client-4-api=4.5.3-2.1',
# 'git-client' => true,
# 'github' => {
#   'group' => 'com.coravy.hudson.plugins.github'
# },
# 'github-api' => true,
# 'github-oauth' => true,
# 'matrix-auth' => true,
# 'scm-api' => true,
# 'job-dsl' => true
