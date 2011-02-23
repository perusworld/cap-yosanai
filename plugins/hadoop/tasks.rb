require 'capistrano'
require 'erb'

set :conf_dir ,"#{File.dirname(__FILE__)}/conf"
set :conf_files ,["core-site.xml","hdfs-site.xml","mapred-site.xml","masters","slaves","hadoop-env.sh"]

namespace :hadoop do
	desc "Setup hadoop on target machines"
	task :setup do
		setup_user
		setup_ssh_keys
		setup_dirs
		setup_binaries
		setup_config
		setup_hosts
		setup_hdfs
	end

	desc "Setup hadoop user"
	task :setup_user, :roles => :hadoop do
		ysystem.setup_user "#{hadoop_user}","#{hadoop_group}"
	end

	desc "Setup ssh keys"
	task :setup_ssh_keys, :roles => :hadoop, :only=>{:key_server => true} do
		setup_main_key
		migrate_keys
	end
	
	desc "Setup main key"
	task :setup_main_key, :roles => :hadoop, :only=>{:key_server => true} do
		ysystem.setup_ssh_keys "#{hadoop_user}","#{hadoop_group}"
	end

	desc "Migrate keys"
	task :migrate_keys, :roles => :hadoop, :except=>{:key_server => true} do
		ysystem.copy_ssh_auth_keys "#{hadoop_user}","#{hadoop_group}"
	end

	desc "Setup directory structure"
	task :setup_dirs, :roles => :hadoop do
		ysystem.setup_dirs "#{hadoop_user}","#{hadoop_group}",["#{hadoop_basedir}"]|hdfs_dirs|mapred_dirs
	end

	desc "Setup hadoop binaries"
	task :setup_binaries, :roles => :hadoop do
	    command =<<-CMD
		  /usr/bin/wget -c '#{hadoop_download_url}' -O #{hadoop_basedir}/#{hadoop_download_file} &&
	      rm -rf #{hadoop_basedir}/#{fetch(:hadoop_download_file).split('/').last.sub('.tar.gz','')} &&
	      cd #{hadoop_basedir} && 
	      tar -xvzf #{hadoop_download_file} &&
		  ln -s #{fetch(:hadoop_download_file).split('/').last.sub('.tar.gz','')} #{hadoop_activedir}
	    CMD
	    invoke_command command, {:via => :sudo}
		invoke_command "/bin/mkdir -p -m 755 #{hadoop_basedir}/#{hadoop_activedir}/logs", {:via => :sudo}
		invoke_command "/bin/chown -R #{hadoop_user}:#{hadoop_group} #{hadoop_basedir}/#{hadoop_activedir}/logs", {:via => :sudo}
	end

	desc "Setup hadoop config files"
	task :setup_config, :roles => :hadoop do
		ysystem.setup_config conf_files,"#{conf_dir}","#{hadoop_basedir}/#{hadoop_activedir}/conf"
	    invoke_command "/usr/bin/dos2unix #{hadoop_basedir}/#{hadoop_activedir}/conf/hadoop-env.sh", {:via => :sudo}
	end

	desc "Setup hosts"
	task :setup_hosts, :roles => :hadoop do
		find_servers(:roles => :hadoop).each do |server|
			ysystem.setup_etc_hosts "#{server.options[:name]}","#{server.host}"
		end
	end

	desc "Setup hdfs"
	task :setup_hdfs, :roles => :hadoop, :only=>{:key_server => true} do
		run "#{sudo :as => "hadoop"}  #{hadoop_basedir}/#{hadoop_activedir}/bin/hadoop namenode -format" do |ch, stream, out|
			logger.debug "#{out}"
			ch.send_data "Y\n" if out =~ /(Y or N)/
		end
	end

	desc "Start nodes"
	task :start, :roles => :hadoop, :only=>{:key_server => true} do
		run "#{sudo :as => "hadoop"}  #{hadoop_basedir}/#{hadoop_activedir}/bin/start-dfs.sh" do |ch, stream, out|
			logger.debug "#{out}"
	 		ch.send_data "yes\n" if out =~ /(yes\/no)/
		end
		run "#{sudo :as => "hadoop"}  #{hadoop_basedir}/#{hadoop_activedir}/bin/start-mapred.sh" do |ch, stream, out|
			logger.debug "#{out}"
	 		ch.send_data "yes\n" if out =~ /(yes\/no)/
		end
	end

	desc "Stop nodes"
	task :stop, :roles => :hadoop, :only=>{:key_server => true} do
		run "#{sudo :as => "hadoop"}  #{hadoop_basedir}/#{hadoop_activedir}/bin/stop-dfs.sh"
		run "#{sudo :as => "hadoop"}  #{hadoop_basedir}/#{hadoop_activedir}/bin/stop-mapred.sh"
	end
	
	
end