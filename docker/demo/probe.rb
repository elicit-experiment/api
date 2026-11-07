# frozen_string_literal: true

# Run inside the initialized demo, using its live jobs service and persistent state.
require 'json'
require 'uri'
require 'timeout'
abort 'This probe is only for the standalone demo' unless ENV['ELICIT_DEMO'] == 'true'

raise 'Primary is not SQLite' unless ActiveRecord::Base.connection.adapter_name == 'SQLite'
raise 'Queue is not SQLite' unless SolidQueue::Record.connection.adapter_name == 'SQLite'
raise 'Uploads are not local' unless ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::DiskService)
raise 'Email deliveries must be disabled' if Rails.configuration.action_mailer.perform_deliveries
raise 'Participant origin mismatch' unless ElicitConfig.participant_url.to_s == "http://#{ENV.fetch('ELICIT_DEMO_HOST', 'localhost')}:#{ENV.fetch('ELICIT_DEMO_EXPERIMENT_PORT', '5505')}"

session = ActionDispatch::Integration::Session.new(Rails.application)
session.host! "#{ENV.fetch('ELICIT_DEMO_HOST', 'localhost')}:#{ENV.fetch('ELICIT_DEMO_PORT', '8080')}"
headers = { 'Accept' => 'text/html' }
session.get('/', headers: headers)
raise "Admin HTML returned #{session.response.status}" unless session.response.status == 200
assets = Nokogiri::HTML(session.response.body).css('script[src],link[href]').filter_map do |element|
  path = element['src'] || element['href']
  path if path.start_with?('/packs/')
end
raise 'No compiled admin assets found' if assets.empty?
assets.each do |path|
  session.get(path)
  raise "Missing compiled asset #{path}" unless session.response.status == 200
end

%w[admin_public webapp_public].each do |client_id|
  secret = ENV.fetch(client_id == 'admin_public' ? 'PUBLIC_CLIENT_SECRET' : 'WEBAPP_CLIENT_SECRET')
  session.post('/api/v1/oauth/token', params: {
    grant_type: 'password', email: 'admin@elicit.com', password: ENV.fetch('ADMIN_PASSWORD'),
    client_id: client_id, client_secret: secret
  })
  raise "OAuth failed for #{client_id}: #{session.response.status}" unless session.response.status == 200
  token = JSON.parse(session.response.body).fetch('access_token')
  session.get('/api/v1/study_definitions', headers: { 'Authorization' => "Bearer #{token}", 'Accept' => 'application/json' })
  raise 'Authenticated API request failed' unless session.response.status == 200
end

blob = nil
begin
  blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('Elicit demo upload probe'),
                                               filename: 'demo-probe.txt', content_type: 'text/plain')
  session.get(URI(Rails.application.routes.url_helpers.rails_blob_url(blob)).request_uri)
  raise 'Local download did not redirect' unless session.response.redirect?
  session.follow_redirect!
  raise 'Local download failed' unless session.response.status == 200 && session.response.body == 'Elicit demo upload probe'
ensure
  blob&.purge
end

job = TestJob.perform_later
Timeout.timeout(30) do
  loop do
    saved = SolidQueue::Job.find_by!(active_job_id: job.job_id)
    raise 'Jobs service failed the probe' if saved.failed_execution
    break if saved.finished_at
    sleep 0.2
  end
end
puts 'PASS: SQLite primary/queue, local uploads/downloads, admin assets, both OAuth clients, authenticated API and live jobs worker'
