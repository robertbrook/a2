require 'mongo_mapper'

class Frame
  include MongoMapper::Document
  
  key :_type, String
  key :timestamp, Time
  key :text, String
end