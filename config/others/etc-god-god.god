# http://unicorn.bogomips.org/SIGNALS.html

rails_root = "/home/vagrant/projects/test-project-deploy-jae"

God.watch do |w|
  w.name = "unicorn"
  w.interval = 30.seconds # default

  # unicorn needs to be run from the rails root
  #w.start = "cd #{rails_root} && bundle exec unicorn -c config/unicorn.rb -D"
  w.start = "cd #{rails_root} && bundle exec unicorn -c config/unicorn.rb -D"

  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{rails_root}/tmp/pids/unicorn.pid`"

  unicorn_pid = "`cat #{rails_root}/tmp/pids/unicorn.pid`"
  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{rails_root}/tmp/pids/unicorn.pid`"
  #w.restart = "kill -QUIT #{unicorn_pid}"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{rails_root}/tmp/pids/unicorn.pid"

  w.uid = 'vagrant'
  w.gid = 'vagrant'

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

# ========= nginx ===================================================

God.watch do |ww|

#  ============ unicorn start/stop/restart =========================

#  ww.start = "cd #{rails_root} && bundle exec unicorn -c config/unicorn.rb -D"
#  ww.stop = "kill -QUIT `cat #{rails_root}/tmp/pids/unicorn.pid`"
#  ww.restart = "kill -USR2 `cat #{rails_root}/tmp/pids/unicorn.pid`"

#  ============ nginx start/stop/restart =========================

  ww.name = "nginx"
  ww.interval = 30.seconds
  ww.start = "/usr/local/sbin/nginx"
#  ww.stop = "kill -QUIT `cat /usr/local/nginx/logs/nginx.pid`"
#  ww.restart = "/usr/local/sbin/nginx -s reload"
  ww.start_grace = 10.seconds
  ww.restart_grace = 10.seconds
  ww.pid_file = "/usr/local/nginx/logs/nginx.pid"
 
  # Cleanup the pid file (this is needed for processes running as a daemon).
  ww.behavior(:clean_pid_file)
 
  # Conditions under which to start the process
  ww.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
 
    start.condition(:process_exits)
  end
  
  # Conditions under which to restart the process
  ww.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 150.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
#  ww.lifecycle do |on|
#    on.condition(:flapping) do |c|
#      c.to_state = [:start, :restart]
#      c.times = 5
#      c.within = 5.minute
#      c.transition = :unmonitored
#      c.retry_in = 10.minutes
#      c.retry_times = 5
#      c.retry_within = 2.hours
#    end
#  end
end
