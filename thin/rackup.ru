require File.dirname(__FILE__)+'/../playlistApp.rb'

set :run, false
set :env, :development

run Sinatra::Application
