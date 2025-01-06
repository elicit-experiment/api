# Configuration parameters for Elicit
# Wraps `Rails.configuration.elicit` and provides helper methods
class ElicitConfig
  include Singleton

  def initialize
    @elicit_frontend = Rails.configuration.elicit[:elicit_portal]
    @participant_frontend = Rails.configuration.elicit[:participant_frontend] # a.k.a. chaos frontend
  end

  def participant_url(session_guid: nil, protocol_definition_id: nil)
    URI("#{@participant_frontend[:scheme]}://#{@participant_frontend[:host]}:#{@participant_frontend[:port]}").tap do |base_uri|
      base_uri.query = "session_guid=#{session_guid}" if session_guid
      base_uri.hash = "Experiment/#{protocol_definition_id}" if protocol_definition_id
    end
  end

  def study_management_url
    URI("#{@elicit_frontend[:scheme]}://#{@elicit_frontend[:host]}:#{@elicit_frontend[:port]}")
  end

  class << self
    delegate :participant_url, :study_management_url, to: :instance
  end
end