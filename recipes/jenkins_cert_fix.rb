# Trust github certificate implicitly
execute 'update-ca-trust' do
  action :nothing
end

directory '/usr/local/share/ca-certificates' do
  recursive true
end

execute 'download ssl cert' do
  command "openssl s_client -showcerts -connect #{node['aw-pipeline']['github']['server']}:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /tmp/#{node['aw-pipeline']['github']['server']}.pem"
  creates "/usr/local/share/ca-certificates/#{node['aw-pipeline']['github']['server']}.pem"
  notifies :run, 'execute[update-ca-trust]'
end

bash 'import_certificate' do
  user 'root'
  returns [0, 1]
  cwd '/tmp'
  code <<-EOH
  /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/bin/keytool -noprompt -import -alias github.sw.ge.com -file /tmp/#{node['aw-pipeline']['github']['server']}.pem -keystore /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.65.x86_64/jre/lib/security/cacerts -storepass changeit
  EOH
end
