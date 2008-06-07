class Pet < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :name, :type
  
  validates_presence_of :name, :message => "can't be blank"
  validates_presence_of :type, :message => "can't be blank"
end
