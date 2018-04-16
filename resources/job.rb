actions :create, :remove
default_action :create

attribute :job_name, name_attribute: true, kind_of: String
attribute :git_url, default: nil, kind_of: String
attribute :git_ver, default: nil, kind_of: String
attribute :branch, default: '*/master', kind_of: String
attribute :polling, default: '* * * * *', kind_of: String
attribute :build_command, default: nil, kind_of: String, required: true
attribute :build_command_var1, default: nil, kind_of: String
attribute :build_command_var2, default: nil, kind_of: String
attribute :cookbook, default: nil, kind_of: String
