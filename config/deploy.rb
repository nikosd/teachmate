set :application, "teachmate.org"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :scm, :git
set :branch, "master"
set :repository, "/var/repos/tm.git"
set :deploy_to, "/var/www/teachmate"
# set :deploy_via, :remote_cache

set :user, "deploy"

role :app, "test-server"
role :web, "test-server"
role :db,  "test-server", :primary => true

#this one prevents chmod (which fails for some reason)
namespace(:deploy) do
  task :finalize_update, :except => { :no_release => true } do
    #run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
    puts 'we don\'t set permissions here anymore'
  end
end

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
