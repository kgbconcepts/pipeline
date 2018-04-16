module Pipeline
  module Helpers
    Chef::Recipe.send :include, self
    # Enumerate each organization in the Chef Server to the given block unless
    # executing Chef in solo mode
    #
    # @param [Proc] block
    def chef_orgs
      if Chef::Config[:solo]
        Chef::Log.warn 'This recipe uses search;' \
                         'Chef solo does not support search'
      else
        search(:chef_orgs, '*:*')
      end
    end

    # Enumerate each cookbook in the Berksfile of the named Chef repo to the
    # given block
    #
    # @param [String] name
    # @param [Proc] block
    def cookbooks_in_berksfile_of_repo(name)
      require 'berkshelf'
      berksfile_from_repo(name).list.reject do |cookbook|
        cookbook.location.nil? || !cookbook.location.is_a?(Berkshelf::GitLocation)
      end
    rescue LoadError
      Chef::Log.warn 'Berkshelf not available'

      []
    end

    # Enumerate each repo of each organization in the Chef Server to the given
    # block
    #
    # @param [proc] block
    def chef_repos
      chef_orgs.map { |org| org['chef_repos'] }.flatten
    end

    # Declare Chef resources for a job to be managed in Jenkins
    #
    # @param [String] name
    # @param [String] git_url
    # @param [String] git_ver
    # @param [String] branch
    # @param [String] polling
    # @param [String] build_command
    # @param [String] build_command_var1
    # @param [String] build_command_var2
    def create_jenkins_job(name, git_url, git_ver, branch, polling, build_command,
                           build_command_var1, build_command_var2, cookbook)
      config_path = path_to_config name

      template config_path do
        source 'job-config.xml.erb'
        variables git_url: git_url, git_ver: git_ver, branch: branch, polling: polling,
                  build_command: build_command, build_command_var1: build_command_var1,
                  build_command_var2: build_command_var2, cookbook: cookbook
      end

      jenkins_job name do
        config config_path
      end
    end

    private

    def berksfile_from_repo(name)
      berksfile_path = path_to_berksfile_of_repo name

      Berkshelf::Berksfile.from_file(berksfile_path).tap do |berksfile|
        install_berksfile berksfile
      end
    end

    def install_berksfile(berksfile)
      Chef::Log.info 'Installing contents of Berksfile...'
      berksfile.lockfile.present? ? berksfile.update : berksfile.install
    end

    def path_to_berksfile_of_repo(name)
      jenkins_cb_name = node[cookbook_name]['jenkins_cb_name']
      node[jenkins_cb_name]['master']['home'] + '/workspace/' + name + \
        '/Berksfile'
    end

    def path_to_config(name)
      file_cache_path = Chef::Config[:file_cache_path]
      file_name = name + '-config.xml'

      ::File.join file_cache_path, file_name
    end
  end
end
