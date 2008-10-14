namespace(:deploy) do
  
  # common options
  APP_NAME = "teachmate"
  USER   = 'deploy'
  COMMIT = (ENV['tag'] || ENV['commit'] || 'HEAD')
  OFF = nil

  # test env only
  TEST_SERVER = 'teachmate-test'
  TEST_DEPLOY_ROOT = "/var/www/#{APP_NAME}"
  TEST_REMOTE_REPO = "/var/repos/tm.git"
  TEST_REMOTE_REPO_NAME = "test"

  # production env only
  SERVER = 'teachmate.org'
  DEPLOY_ROOT = "/var/www/#{APP_NAME}"
  REMOTE_REPO = "/var/repos/tm.git"
  REMOTE_REPO_NAME = ""

  def set_options(env)
    if env == :test
      @server           = TEST_SERVER
      @deploy_root      = TEST_DEPLOY_ROOT
      @remote_repo      = TEST_REMOTE_REPO
      @remote_repo_name = TEST_REMOTE_REPO_NAME
    elsif env == :production
      @server           = SERVER
      @deploy_root      = DEPLOY_ROOT
      @remote_repo      = REMOTE_REPO
      @remote_repo_name = REMOTE_REPO_NAME
    end
  end

  
  namespace(:test) do
    task :new do
      set_options(:test)
      new
    end
    task :revert do
      set_options(:test)
      revert
    end
    task :stop do
      set_options(:test)
      stop
    end
    task :maintenance do
      set_options(:test)
      maintenance
    end
  end

  
  task :new do
    set_options(:production)
    new
  end
  task :revert do
    set_options(:production)
    revert
  end
  task :stop do
    set_options(:production)
    stop
  end

  def new
    

    begin
      puts "server is #{@server}"
      puts "pushing git repo..."

      if COMMIT =~ /^HEAD/
        current_rev = `git rev-parse #{COMMIT}`.chomp
      else
        current_rev = COMMIT
      end

      `git push #{@remote_repo_name}`
      `git push --tags #{@remote_repo_name}`

      remote "cloning repo to release dir", "git fetch #{@remote_repo} && git fetch --tags #{@remote_repo}"
      
      unless remote("", "git rev-parse HEAD").chomp == current_rev
        remote "storing previous commit id",  "git rev-parse HEAD > previous_release.log" 
      end
      
      remote "checking out #{COMMIT}",      "git checkout -f #{current_rev}"
      remote "updating submodules",         "git submodule update"
      remote "migrating DB",                "rake db:migrate RAILS_ENV=migration"
      remote "restarting mongrels",         "mongrel_cluster_ctl restart"
      
      system 'echo "\033[1;32mRunning ' + remote("", "git describe --tags HEAD").chomp + ' now\033[0m"'
    ensure
    end
  end

  def revert
    prev = remote("", 'cat previous_release.log') 
    remote "reverting to previous release", "git checkout #{prev}"
  end

  def stop
    remote "stopping mongrels", "mongrel_cluster_ctl stop"
  end

  def maintenance
    if OFF.nil?
      remote "creating link to _maintenance.html file", "cd public; ln -s _maintenance.html maintenance.html"
    else
      remote "removing link to _maintenance.html file", "rm public/maintenance.html"
    end
  end

  def remote(message, code)
    puts "#{message}..." unless message.empty?
    `ssh #{@server} -l #{USER} \"cd #{@deploy_root}/release && #{code}"`
  end

end
