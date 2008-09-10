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
      remote "storing previous commit id",  "git rev-parse HEAD > previous_release.log"
      remote "checking out #{COMMIT}",      "git checkout #{current_rev}"
    ensure
    end
  end

  task :revert do
    prev = remote("hello", 'cat previous_release.log') 
    remote "reverting to previous release", "git checkout #{prev}"
  end

  def remote(message, code)
    puts "#{message}..."
    `ssh #{SERVER} -l #{USER} \"cd #{DEPLOY_ROOT}/release && #{code}"`
  end

end
