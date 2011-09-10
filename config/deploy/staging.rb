default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

set :user, "root"

set :temp_dir, "/tmp"
set :hadoop_basedir, "/usr/local/hadoop"
set :hadoop_activedir, "latest"
set :hadoop_user, "hadoop"
set :hadoop_group, "hadoop"
set :dfs_permissions_enabled, "false"
set :dfs_permissions_supergroup, "hadoop"
set :update_etc_localhost, true

set :hdfs_dirs, ["/mnt/hdfs/mirror1/name","/mnt/hdfs/mirror1/data"]
set :mapred_dirs, ["/mnt/mapred/mirror1/local"]

set :hadoop_download_file, "hadoop-0.20.2.tar.gz"
set :hadoop_download_url, "http://www.gtlib.gatech.edu/pub/apache//hadoop/core/hadoop-0.20.2/#{hadoop_download_file}"

set :java_home, "/usr/local/java/latest"

role :hadoop, "hadoop-name-node", :ip => "192.168.30.243", :namenode => true, :key_server => true, :maprednode => true
role :hadoop, "hadoop-data-node-1", :ip => "192.168.30.227", :datanode => true
role :hadoop, "hadoop-data-node-2", :ip => "192.168.30.137", :datanode => true
role :hadoop, "hadoop-data-node-3", :ip => "192.168.30.201", :datanode => true
role :hadoop, "hadoop-data-node-4", :ip => "192.168.30.188", :datanode => true
role :hadoop, "hadoop-data-node-5", :ip => "192.168.30.127", :datanode => true
