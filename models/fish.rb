class Fish < ActiveRecord::Base
  belongs_to :user
  validates :name, :presence => {:message => "is required"}
  validates :wikipedia_page, :presence => {:message => "is required"}
end