# frozen_string_literal: true

# Executed by a Playwright fixture via rails runner; never exposed as an HTTP route.
raise 'Smoke fixtures require the owned test harness' unless Rails.env.test? && ENV['ELICIT_E2E'] == '1'

require 'json'
require 'securerandom'

root = Pathname.new(ENV.fetch('ELICIT_E2E_ROOT')).realpath
output = Pathname.new(ENV.fetch('ELICIT_E2E_FIXTURE_FILE')).expand_path
raise 'Fixture output must live inside the owned temporary root' unless output.dirname.realpath == root

fixture = JSON.parse(Rails.root.join('test/e2e/data/study-v1.json').read)
namespace = SecureRandom.hex(8)
password = SecureRandom.hex(16)
manifest = nil

ActiveRecord::Base.transaction do
  # Rails does not seed test databases with deployment accounts. Provision only
  # the synthetic browser OAuth client needed by the normal login flow.
  OauthApplication.find_or_create_by!(uid: ENV.fetch('WEBAPP_CLIENT_ID')) do |application|
    application.name = 'Smoke browser client'
    application.secret = ENV.fetch('WEBAPP_CLIENT_SECRET')
    application.redirect_uri = '/admin'
  end
  researcher = User.create!(email: "researcher-#{namespace}@example.invalid", username: "researcher-#{namespace}",
                            password: password, role: User::ROLES.fetch(:investigator))
  participant = User.create!(email: "participant-#{namespace}@example.invalid", username: "participant-#{namespace}",
                             password: SecureRandom.hex(16), role: User::ROLES.fetch(:anonymous))
  study = StudyDefinition.create!(title: "#{fixture.fetch('title')} #{namespace}",
                                  principal_investigator: researcher, version: fixture.fetch('version'),
                                  lock_question: 0, enable_previous: 1, allow_anonymous_users: true,
                                  show_in_study_list: false, redirect_close_on_url: '/participant')
  protocol = ProtocolDefinition.create!(study_definition: study, name: 'Smoke protocol', active: true,
                                        definition_data: '{}')
  phase = PhaseDefinition.create!(study_definition: study, protocol_definition: protocol, definition_data: '{}')
  protocol_user = ProtocolUser.create!(protocol_definition: protocol, user: participant, group_name: namespace)
  origin = { study_definition: study, protocol_definition: protocol, phase_definition: phase }
  trials = fixture.fetch('trials').to_h do |definition|
    trial = TrialDefinition.create!(**origin, name: definition.fetch('key'), definition_data: '{"type":"NewComponent"}')
    component_data = {
      Instruments: [{ Instrument: { definition.fetch('type') => definition.fetch('instrument') } }],
      Stimuli: [], Layout: { Type: 'row', ColumnWidthPercent: nil }
    }
    component = Component.create!(**origin, trial_definition: trial, name: definition.fetch('key'),
                                   definition_data: JSON.generate(component_data))
    [definition.fetch('key'), { trial_id: trial.id, component_id: component.id }]
  end
  TrialOrder.create!(**origin, user: participant, sequence_data: trials.values.map { |trial| trial.fetch(:trial_id) }.join(','))
  manifest = {
    version: fixture.fetch('version'), namespace: namespace, study_id: study.id, title: study.title,
    protocol_id: protocol.id, protocol_user_id: protocol_user.id, participant_id: participant.id,
    researcher: { email: researcher.email, password: password }, trials: trials
  }
end

output.write(JSON.pretty_generate(manifest))
