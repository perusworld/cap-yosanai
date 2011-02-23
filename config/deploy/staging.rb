default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

set :user, "root"

set :temp_dir, "/tmp"
set :hadoop_basedir, "/usr/local/hadoop"
set :hadoop_activedir, "latest"
set :hadoop_user, "hadoop"
set :hadoop_group, "hadoop"

set :hdfs_dirs, ["/mnt/hdfs/mirror1/name","/mnt/hdfs/mirror1/data"]
set :mapred_dirs, ["/mnt/mapred/mirror1/local"]

set :hadoop_download_file, "hadoop-0.20.2.tar.gz"
set :hadoop_download_url, "http://www.gtlib.gatech.edu/pub/apache//hadoop/core/hadoop-0.20.2/#{hadoop_download_file}"

set :java_home, "/usr/java/default"

role :hadoop,  "192.168.137.107", :name => "peruhadoopname", :namenode => true, :key_server => true, :maprednode => true
role :hadoop,  "192.168.137.111", :name => "peruhadoopdata", :datanode => true