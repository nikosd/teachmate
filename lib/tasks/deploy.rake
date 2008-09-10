namespace(:deploy) do

  APP_NAME = "teachmate"
  SERVER = 'tm-server'
  USER   = 'deploy'
  DEPLOY_ROOT = "/var/www/#{APP_NAME}"
  
  task :go do
    COMMIT = (ENV['tag'] || ENV['commit'] || 'HEAD')

    begin
#       sh "git archive --format=tar #{COMMIT} | gzip > /tmp/#{@archive_name}"
#       sh "scp /tmp/#{@archive_name} #{USER}@#{SERVER}:#{DEPLOY_ROOT}/releases/"

      puts "pushing git repo..." and sh 'git push'

      remote "cloning repo to release dir", "git fetch /var/repos/tm.git"
      remote "checking out #{COMMIT}",      "git checkout #{COMMIT}"
      remote "storing previous commit id"
    ensure
    end
  end

  task :revert do
    
  end

  def remote(message, code)
    puts "#{message}..."
    sh("ssh #{SERVER} -l #{USER} \"cd #{DEPLOY_ROOT}/release && " + code + '"')
  end

end
