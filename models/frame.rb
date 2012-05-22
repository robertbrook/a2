require 'mongo_mapper'

class Frame
  include MongoMapper::Document
  
  key :timestamp, Time
  key :text, String
end