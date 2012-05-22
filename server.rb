require 'sinatra'
require 'mongo_mapper'

MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]
env = {}
MongoMapper.config = { env => {'uri' => MONGO_URL} }
MongoMapper.connect(env)

require_relative 'models/frame'

get "/" do
end

#editing screen to add new frame
get "/edit/add" do
end

#submitted screen for validation/saving
post "/edit/add" do
end
