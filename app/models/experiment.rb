class Experiment < ApplicationRecord
  #one to many relationship to TrialS
  has_many :trials
  #do some data validation
  validates :name, presence:true,
  length: {minimum: 1}
end
