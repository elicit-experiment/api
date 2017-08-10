class ProtocolsStudy < ApplicationRecord
  has_one :study, :class_name => "Study", :foreign_key => "study_id"
  has_one :protocol, :class_name => "Protocol", :foreign_key => "protocol_id"
end
