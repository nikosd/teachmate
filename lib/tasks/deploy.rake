namespace(:deploy) do

  APP_NAME = "teachmate"
  SERVER = 'tm-server'
  USER   = 'deploy'
  DEPLOY_ROOT = "/var/www/#{APP_NAME}"
  
  task :go do
    TAG = (ENV['tag'])
    COMMIT = (ENV['tag'] || ENV['commit'] || 'HEAD')
    VERSION_NAME = (ENV['version_name'] || TAG || Time.now.strftime("%Y-%m-%d_%H-%M-%S"))
    @archive_name = "#{APP_NAME}_#{VERSION_NAME}.tar.gz"
    @remote_code = ""

    begin
      sh "git archive --format=tar #{COMMIT} | gzip > /tmp/#{@archive_name}"
      sh "scp /tmp/#{@archive_name} #{USER}@#{SERVER}:#{DEPLOY_ROOT}/releases/"

      remote "cd #{DEPLOY_ROOT}/releases && mkdir #{VERSION_NAME} && cd #{VERSION_NAME}"
      remote "tar -xvvzf ../#{@archive_name} && cd .."
      remote "unlink #{@archive_name}"
      remote "cd .. && unlink current && ln -s releases/#{VERSION_NAME} current"
      
      exec_remote 
    ensure
      #cleanup happens here
      sh "unlink /tmp/#{@archive_name}"
    end
  end

  def remote(code)
    amp = ' && ' unless @remote_code.empty?
    @remote_code += "#{amp}#{code}"
  end

  def exec_remote
    sh("ssh #{SERVER} -l #{USER} \"" + @remote_code + '"')
    @remote_code = ""
  end

end
