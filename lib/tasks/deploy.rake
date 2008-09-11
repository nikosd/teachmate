namespace(:deploy) do

  APP_NAME = "teachmate"
  SERVER = 'tm-server'
  USER   = 'deploy'
  DEPLOY_ROOT = "/var/www/#{APP_NAME}"
  
  task :new do
    COMMIT = (ENV['tag'] || ENV['commit'] || 'HEAD')

    begin
      puts "pushing git repo..."

      if COMMIT =~ /^HEAD/
        current_rev = `git rev-parse #{COMMIT}`.chomp
      else
        current_rev = COMMIT
      end

      `git push`
      `git push --tags`

      remote "cloning repo to release dir", "git fetch /var/repos/tm.git && git fetch --tags /var/repos/tm.git"
      
      unless remote("", "git rev-parse HEAD").chomp == current_rev
        remote "storing previous commit id",  "git rev-parse HEAD > previous_release.log" 
      end
      
      remote "checking out #{COMMIT}",      "git checkout #{current_rev}"
      remote "updating submodules",         "git submodule update"
      remote "migrating DB",                "rake db:migrate RAILS_ENV=migration"
      remote "restarting mongrels",         "mongrel_cluster_ctl restart"
      
      system 'echo "\033[1;32mRunning ' + remote("", "git describe --tags HEAD").chomp + ' now\033[0m"'
    ensure
    end
  end

  task :revert do
    prev = remote("", 'cat previous_release.log') 
    remote "reverting to previous release", "git checkout #{prev}"
  end

  task :stop do
    remote "stopping mongrels", "mongrel_cluster_ctl stop"
  end

  def remote(message, code)
    puts "#{message}..." unless message.empty?
    `ssh #{SERVER} -l #{USER} \"cd #{DEPLOY_ROOT}/release && #{code}"`
  end

end
