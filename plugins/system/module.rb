require 'capistrano'
require 'erb'

module YSystem 
	def setup_user(user,group,options = {},home_root = '/home', file_perms = '700')
		options.merge({:via => :sudo})
		invoke_command "/usr/sbin/groupadd -f -r #{group}", options rescue nil
		invoke_command "/usr/sbin/useradd -b #{home_root} -m #{user} -g #{group}", options rescue nil
		invoke_command "/bin/mkdir -p -m #{file_perms} #{home_root}/#{user}/.ssh", options
		invoke_command "/bin/chown -R #{user}:#{group} #{home_root}/#{user}/.ssh", options
	end

	def setup_ssh_keys(user,group,options = {},home_root = '/home')
		options.merge({:via => :sudo})
	    command =<<-CMD
		  	/bin/ls #{home_root}/#{user}/.ssh && 
		  	if [ -e #{home_root}/#{user}/.ssh/id_dsa ]; then echo 'skipping key creation'; else /usr/bin/ssh-keygen -q -t dsa -P '' -f #{home_root}/#{user}/.ssh/id_dsa; fi &&
			/bin/cat #{home_root}/#{user}/.ssh/id_dsa.pub > #{home_root}/#{user}/.ssh/authorized_keys &&
			/bin/chown -R #{user}:#{group} #{home_root}/#{user} &&
			/bin/chmod -R 700 #{home_root}/#{user}/.ssh
	    CMD
	    invoke_command command, options
	    get "#{home_root}/#{user}/.ssh/authorized_keys","/tmp/authorized_keys"
	end

	def copy_ssh_auth_keys(user,group,options = {},home_root = '/home')
		options.merge({:via => :sudo})
	    upload "/tmp/authorized_keys","#{home_root}/#{user}/.ssh/authorized_keys"
	    command =<<-CMD
			/bin/chown -R #{user}:#{group} #{home_root}/#{user} &&
			/bin/chmod -R 700 #{home_root}/#{user}/.ssh
	    CMD
	    invoke_command command, options
	end

	def setup_dirs(user,group,dirs = {},options = {}, file_perms = '755')
		dirs.each do |dir|
			invoke_command "/bin/mkdir -p -m #{file_perms} #{dir}", {:via => :sudo}
			invoke_command "/bin/chown -R #{user}:#{group} #{dir}", {:via => :sudo}
		end
	end

	def setup_config(conf_files = {},src_dir=nil,target_folder=nil)
		conf_files.each do |conf_file|
			data = ERB.new(File.read("#{src_dir}/#{conf_file}.erb")).result(binding)
			put data, "#{target_folder}/#{conf_file}"
		end
	end

	def setup_etc_hosts(host,ipaddress,options = {})
		options.merge({:via => :sudo})
	    command =<<-CMD
	   	  grep -v #{host} /etc/hosts > /etc/hosts_cp &&
	   	  echo "#{ipaddress}\t#{host}" >> /etc/hosts_cp &&
	   	  cp -f /etc/hosts_cp /etc/hosts
	    CMD
	    invoke_command command, options
	end

end

Capistrano.plugin :ysystem, YSystem
