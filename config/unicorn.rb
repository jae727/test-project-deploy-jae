working_directory "/home/vagrant/projects/test-project-deploy-jae"
pid "tmp/pids/unicorn.pids"
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

#This will create the unicorn.sock file at this location. 
#Listens on the given Unix socket
#backlog = number of clients

listen "/home/vagrant/projects/test-project-deploy-jae/tmp/sockets/unicorn.sock", :backlog => 64
worker_processes 2
timeout 30
