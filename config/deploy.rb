set :application, "teachmate.org"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :scm, :git
set :branch, "master"
set :repository, "/home/roman/tm.git"
set :deploy_to, "/var/www/teachmate"
# set :deploy_via, :remote_cache

set :user, "roman"

role :app, "test-server"
role :web, "test-server"
role :db,  "test-server", :primary => true

# custom tasks
after "deploy", "init_submodules"

task :init_submodules, :roles => :app do
  run "cd #{current_path}; git submodule init; git submodule update"
end

namespace(:deploy) do
  task :restart do
    # nothing here yet
  end
end
