require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/json'
configure do
  set :bind, '0.0.0.0'
end

get '/' do
  "Hi there! I'm client :)"
end

