# frozen_string_literal: true

# A CHAOS experiment is equivalent to a protocol
class ChaosExperimentService
  include Rails.application.routes.url_helpers
  include Denilize

  attr_accessor :study_definition, :protocol_definition, :phase_definition, :trial_definition, :study_result

  def initialize(study_definition, protocol_definition = nil, phase_definition = nil, user_id = nil)
    @study_definition = study_definition
    @protocol_definition = protocol_definition
    @phase_definition = phase_definition
    @trial_definition = nil
    @protocol_definition ||= ProtocolDefinition.where(
      study_definition_id: @study_definition.id
    ).first
    if @protocol_definition.nil?
      Rails.logger.error "No protocols for study #{study_definition.ai}"
      # TODO: we should handle malformed studies by erroring appropriately
    end
    @phase_definition ||= PhaseDefinition.where(
      study_definition_id: @study_definition.id,
      protocol_definition_id: @protocol_definition.id
    ).first
    @user_id = user_id
  end

  def make_experiment(experiment)
    stage = experiment.current_stage
    {
      Name: @study_definition.title,
      Css: '',
      Version: @study_definition.version,
      CreatedBy: @study_definition.principal_investigator_user_id.to_s,
      # ExperimentDescription: @study_definition.description,
      # Data: @study_definition.data,
      #      RedirectOnCloseUrl: @study_definition.redirect_close_on_url,
      LockQuestion: @study_definition.lock_question == 1,
      EnablePrevious: @study_definition.enable_previous == 1,
      NoOfTrials: stage.num_trials,
      TrialsCompleted: stage.trials_completed,
      FooterLabel: @study_definition.footer_label,
      RedirectOnCloseUrl: chaos_endexperiment_url,
      CurrentSlideIndex: stage.current_trial,
      Fullname: 'Questionnaire, 1.0'
    }
  end

  def preview_trial_definitions
    trial_params = { study_definition_id: @study_definition.id,
                     protocol_definition_id: @protocol_definition.id,
                     phase_definition_id: @phase_definition.id }
    TrialDefinition.where(trial_params)
  end

  def make_preview_experiment(trial_definition_id)
    trial_ids = preview_trial_definitions.map(&:id)
    num_trials = trial_ids.count

    current_trial_idx = trial_ids.index(trial_definition_id)

    elicit_config = Rails.configuration.elicit['elicit_portal']
    url = "#{elicit_config[:scheme]}://#{elicit_config[:host]}:#{elicit_config[:port]}/admin/studies/#{@study_definition.id}/protocols/#{@protocol_definition.id}"

    trials_completed = current_trial_idx ? (current_trial_idx - 1) : nil

    {
      Name: @study_definition.title,
      Css: '',
      Version: @study_definition.version,
      # ExperimentDescription: @study_definition.description,
      CreatedBy: @study_definition.principal_investigator_user_id.to_s,
      # Data: @study_definition.data,
      LockQuestion: @study_definition.lock_question == 1,
      EnablePrevious: @study_definition.enable_previous == 1,
      NoOfTrials: num_trials,
      TrialsCompleted: trials_completed,
      FooterLabel: @study_definition.footer_label,
      RedirectOnCloseUrl: url,
      CurrentSlideIndex: current_trial_idx,
      Fullname: 'Questionnaire, 1.0'
    }
  end

  def trial_for_slide_index(trial_no = 0)
    @trial_order = @phase_definition.trial_order_for_user @user_id

    @trials = []

    if @trial_order.nil?
      # TODO: since we just need one of these, this would be better written as an offset/limit query
      @trials = TrialDefinition.where(trial_query).order(:id).entries
      @trial_sequence = TrialOrder.default_sequence(@trials)
      @trial_definition = @trials.detect { |trial| trial.id == @trial_sequence[trial_no] }
    else
      @trial_sequence = @trial_order.sequence_data.split(',').map(&:to_i)
      @trial_definition = TrialDefinition.find(@trial_sequence&.[](trial_no))
    end

    unless @trial_definition
      Rails.logger.error "Trial order #{@trial_order.ai} sequence #{@trial_sequence.ai} contains invalid ids #{@trials.ai} for trial index #{trial_no}"
    end

    @trial_definition
  end

  # make the slide for the given trial number (a.k.a. slide number)
  def make_slide(trial_no = 0, protocol_user_id = nil, trial_definition = nil)
    @trial_definition = trial_definition || trial_for_slide_index(trial_no)

    return ChaosResponse.new(nil, "Cannot find definition for index #{trial_no}") unless @trial_definition

    @components = Component.where(trial_query.merge(trial_definition_id: @trial_definition.id)).order(:id).entries
    # @stimuli = Stimulus.where(trial_query).order(:id).entries

    begin
      trial_data = JSON.parse(@trial_definition.definition_data)
      type = (trial_data['type']) if trial_data.key? 'type'
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse trial definition data='#{@trial_definition.definition_data}'"
      Rails.logger.error e.ai
    end

    chaos_trial = if @components.empty?
                    # allow no-component slides to be generated by the data definition of the trial
                    [{
                      'Type': type,
                      'Id': "#{@study_definition.id}:0:#{@trial_definition.id}",
                      'Fullname': 'NewComponent, 1.0.0',
                      'UserAnswer': nil,
                      'Component': trial_data
                    }]
                  else
                    @components.map do |c|
                      outputs = {}
                      unless protocol_user_id.nil?
                        data_points = StudyResult::DataPoint.where(component_id: c.id, protocol_user_id: protocol_user_id)
                        events = data_points.entries.reject { |d| (d.point_type.eql? 'State') }.map do |data_point|
                          next unless data_point.point_type != 'State'

                          {
                            'Type' => data_point.point_type,
                            'EventId' => data_point.kind,
                            'Data' => data_point.value,
                            'Method' => data_point.method,
                            'DateTime' => data_point.datetime
                          }
                        end
                        state = data_points.entries.find { |d| d.point_type.eql? 'State' }
                        outputs = JSON.parse(state.value) if state
                      end

                      begin
                        component_data = JSON.parse(c.definition_data || '{}')
                      rescue JSON::ParserError => e
                        Rails.logger.error "Failed to parse component definition data='#{c.definition_data}'"
                        Rails.logger.error e.ai
                      end

                      type ||= 'NewComponent'

                      chaos_component = {
                        'Type': type,
                        'Id': "#{@study_definition.id}:#{c.id}",
                        'Fullname': 'NewComponent, 1.0.0',
                        'UserAnswer': nil,
                        'Component': component_data
                      }

                      chaos_component
                    end.flatten
                  end

    # ap chaos_trial
    # ap @components

    response = ChaosResponse.new(chaos_trial)

    # These are necessary to set the counts up for "Slide N/M" in the Chaos frontend
    response.Body['FoundCount'] = (@trial_sequence || TrialDefinition.where(trial_query)).size
    response.Body['StartIndex'] = trial_no

    response
  end

  private

  def trial_query
    {
      study_definition_id: @study_definition.id,
      protocol_definition_id: @protocol_definition.id,
      phase_definition_id: @phase_definition.id
    }
  end
end
