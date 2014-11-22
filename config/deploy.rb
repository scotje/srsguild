default_run_options[:pty] = true

set :application, "srsguild"
set :user, "admin"

set :repository,  "admin@git.vanisher.net:/home/git/srsguild.git"

set :scm, :git
set :branch, "master"

#set :scm, :subversion
#set :scm_username, "jesse"
#set :scm_auth_cache, true
set :deploy_via, :remote_cache
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "srsguild.com"                          # Your HTTP server, Apache/etc
role :app, "srsguild.com"                          # This may be the same as your `Web` server
role :db,  "srsguild.com", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

set :deploy_to, "/home/apps/#{application}"
set :use_sudo, false

desc "Write current SVN revision to partial template."
task :publish_revision do
  run "echo \"#{real_revision[0..7]}\" > #{release_path}/app/views/layouts/_revision.html.erb"
end

desc "Symlink database.yml"
task :symlink_db_config do
  run "/bin/ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
end

task :after_update_code do 
  publish_revision
  symlink_db_config
end

namespace :deploy do
  task :start do
  end
  
  task :stop do
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
