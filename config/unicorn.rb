wd="/home/vagrant/projects/test-project-deploy-jae"
working_directory "/home/vagrant/projects/test-project-deploy-jae"

#pid "tmp/pids/unicorn.pids"
pid "/home/vagrant/projects/test-project-deploy-jae/tmp/pids/unicorn.pid"

stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

#This will create the unicorn.sock file at this location. 
#Listens on the given Unix socket
#backlog = number of clients

listen "/home/vagrant/projects/test-project-deploy-jae/tmp/sockets/unicorn.sock", :backlog => 64
worker_processes 2
timeout 30

after_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  #old_pid = "#{wd}/tmp/pids/unicorn.pid.oldbin"
  #old_pid = "/home/vagrant/projects/test-project-deploy-jae/tmp/pids/unicorn.pid.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errono::ESRCH
      # someone else did our job for us
    end
  end
end
