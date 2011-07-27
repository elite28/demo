require 'bundler/capistrano'
set :application, "demo"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git@github.com:elite28/demo.git"  # Your clone URL
set :branch, "master"
set :scm, "git"
set :user, "mos"  # The server's user for deploys
set :deploy_to, "/var/www/demo"
set :deploy_via, :remote_cache
set :use_sudo, false

ssh_options[:forward_agent] = true

# default_environment['PATH']= '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/ruby-enterprise-1.8.7-2011.03/bin'
# default_environment['GEM_PATH']= '/opt/ruby-enterprise-1.8.7-2011.03/lib/ruby/gems/1.8'

set :git_shallow_clone, 1
set :git_enable_submodules, 1

role :web, "118.126.15.202"                          # Your HTTP server, Apache/etc
role :app, "118.126.15.202"                          # This may be the same as your `Web` server
role :db,  "118.126.15.202", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    # run "mkdir #{release_path}/public/stylesheets/compiled"
    # run "chmod 0777 #{release_path}/public/stylesheets/compiled"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'

namespace :db do
  desc "migrate db"
  task :migrate, :roles => :app do
    run "cd #{release_path} && RAILS_ENV=production rake db:migrate"
  end
end


