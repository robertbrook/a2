require 'sinatra'
require 'mongo_mapper'

MONGO_URL = ENV['MONGOHQ_URL'] || YAML::load(File.read("config/mongo.yml"))[:mongohq_url]
env = {}
MongoMapper.config = { env => {'uri' => MONGO_URL} }
MongoMapper.connect(env)

require_relative 'models/frame'

helpers do
  def title_text
    if params[:title]
      params[:title]
    elsif @frame
      @frame.title
    else
      ""
    end
  end
  
  def frame_text
    if params[:text]
      params[:text]
    elsif @frame
      @frame.text
    else
      ""
    end
  end
  
  def timestamp_text
    if params[:ts]
      params[:ts]
    elsif @frame
      @frame.timestamp
    else
      Time.now()
    end
  end
end

get "/" do
  unless params[:prev]
    @frame = Frame.last(:order => :timestamp.asc)
  else
    if params[:dir] == "back"
      dir = "earlier"
      @frame = Frame.where(:timestamp => {:$lt => params[:prev].to_time}).limit(1).sort(:timestamp.desc).first
    else
      dir = "later"
      @frame = Frame.where(:timestamp => {:$gt => params[:prev].to_time}).limit(1).sort(:timestamp.asc).first
    end
  end
  unless @frame
    @frame = Frame.where(:timestamp => params[:prev].to_time).first
    if params[:dir]
      @error = "Sorry, could not find the #{dir} frame you requested. Here's the last one you saw"
    else
      @error = "Sorry, something seems to have gone wrong, returning to the start"
      @frame = Frame.last(:order => :timestamp.asc)
    end
  end
  haml :index
end

#admin home screen
get "/admin/?" do
  @frames = Frame.all
  haml :admin
end

#input screen to add new frame
get "/admin/new/?" do
  haml :admin_edit
end

#submitted frame for validation/saving
post "/admin/new" do
  # check everything's ok...
  
  # ...it is? Great, save the object
  frame = Frame.new
  frame.title = params["title"]
  frame.timestamp = params["ts"]
  frame.text = params["text"]
  frame.save
  
  #aaand back to the list screen (uh, kinda assuming everything's ok still)
  redirect "/admin"
end

#view/edit a frame
get "/admin/:id/?" do
  @frame = Frame.find(params[:id])
  haml :admin_edit
end

#handle the form submit
post "/admin/:id/?" do
  frame = Frame.find(params[:id])
  frame.title = params["title"]
  frame.timestamp = params["ts"]
  frame.text = params["text"]
  frame.save
  
  redirect "/admin"
end