set :application, "teachmate.org"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"
set :repository, "/home/roman/tm.git"
set :deploy_to, "/var/www/teachmate"
# set :deploy_via, :remote_cache

set :user, "roman"

role :app, "test-server"
role :web, "test-server"
role :db,  "test-server", :primary => true
