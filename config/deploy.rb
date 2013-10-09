set :application, "app1"
set :repository,  "git@github.com:hayesmp/railsgirls-app.git"
set :branch, "master"
set :keep_releases, 5


# Code Repository
# =========
set :scm, :git
set :scm_verbose, true
set :deploy_via, :remote_cache

# Remote Server
# =============
set :use_sudo, false
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# Bundler
# -------
require 'bundler/capistrano'
set :bundle_flags, "--deployment --binstubs"
set :bundle_without, [:test, :development, :deploy]

# Rbenv
# -----
default_run_options[:shell] = '/bin/bash --login'


# Rails: Asset Pipeline
# ---------------------
#load 'deploy/assets'

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts


# Server specific
# ----------------
set :user, "root"
server "198.61.170.19", :web, :app, :db, :primary => true
set :deploy_to, "/home/apps/#{application}"
set :rails_env, "production"


# Data migration task
# ----------------
namespace :migrate do
  task :data do
    shellwords = Shellwords.shellwords(`heroku info -s`)
    pairs = shellwords.map{ |s| s.split('=', 2) }.flatten
    h = Hash[*pairs]
    _cset(:heroku_app) {h['name']}


    if db_config = YAML.load_file('config/database.yml')['production']
      api_key = `heroku auth:token`
      remote_db = "mysql2://#{db_config['username']}:#{db_config['password']}@#{db_config['host']}:#{db_config['port']}/#{db_config['database']}"
      run "HEROKU_API_KEY=#{api_key} bash -c 'cd /home/apps/app1/current && bundle exec heroku db:pull #{remote_db} --app #{heroku_app} --confirm #{heroku_app}'"
    end
  end
end


# If you are using Passenger mod_rails uncomment this:
#namespace :deploy do
#  task :start do
#    run "sudo sv up app1"
#  end
#  task :stop do
#    run "sudo sv down app1"
#  end
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "sudo sv restart app1"
#  end
#end