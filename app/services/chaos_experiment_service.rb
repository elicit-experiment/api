# frozen_string_literal: true

# A CHAOS experiment is equivalent to a protocol
class ChaosExperimentService
  include Denilize

  attr_accessor :study_definition
  attr_accessor :protocol_definition
  attr_accessor :phase_definition
  attr_accessor :trial_definition
  attr_accessor :study_result

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
      # ExperimentDescription: @study_definition.description,
      CreatedBy: @study_definition.principal_investigator_user_id.to_s,
      # Data: @study_definition.data,
      LockQuestion: @study_definition.lock_question == 1,
      EnablePrevious: @study_definition.enable_previous == 1,
      NoOfTrials: stage.num_trials,
      TrialsCompleted: stage.trials_completed,
      FooterLabel: @study_definition.footer_label,
      RedirectOnCloseUrl: @study_definition.redirect_close_on_url,
      CurrentSlideIndex: stage.current_trial,
      Fullname: 'Questionnaire, 1.0'
    }
  end

  def get_preview_trial_definitions
    trial_params = { study_definition_id: @study_definition.id,
                     protocol_definition_id: @protocol_definition.id,
                     phase_definition_id: @phase_definition.id }
    TrialDefinition.where(trial_params)
  end

  def make_preview_experiment(trial_definition_id)
    trial_ids = get_preview_trial_definitions.map(&:id)
    num_trials = trial_ids.count

    current_trial_idx = trial_ids.index(trial_definition_id)

    elicit_config = Rails.configuration.elicit['elicit_portal']
    url = elicit_config['scheme'] + '://' +
          elicit_config['host'] + ':' +
          elicit_config['port'].to_s + '/admin/studies/' +
          @study_definition.id.to_s + '/protocols/' +
          @protocol_definition.id.to_s

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
    # TODO: since we just need one of these, this would be better written as an offset/limit query
    @trials = TrialDefinition.where(trial_query).order(:id).entries

    @trial_order = TrialOrder.where(trial_query.merge(user_id: @user_id)).first

    if @trial_order.nil?
      if @phase_definition.trial_ordering == 'RandomWithReplacement'
        @trial_order = TrialOrder.where(trial_query.merge(user_id: nil)).order('RANDOM()').first
      elsif @phase_definition.trial_ordering == 'RandomWithoutReplacement'
        @trial_order = TrialOrder
                       .where(trial_query.merge(user_id: nil))
                       .left_joins(:trial_order_selection_mappings)
                       .where(trial_order_selection_mappings: { id: nil }).first
      else
        @trial_order = TrialOrder.where(trial_query.merge(user_id: nil)).order('RANDOM()').first
      end

      if @trial_order.nil?
        all_trial_orders = TrialOrder.where(trial_query)
        Rails.logger.error "Cannot find suitable non-user TrialOrder or user trial for #{@user_id} amongst #{all_trial_orders.ai}"
        return nil
      end

      TrialOrderSelectionMapping.create!(trial_order: @trial_order,
                                         user_id: @user_id,
                                         phase_definition: @phase_definition)
    end

    @trial_sequence = if @trial_order.nil?
                        TrialOrder.default_sequence(@trials)
                      else
                        @trial_order.sequence_data.split(',').map(&:to_i)
                      end

    @trial_definition = @trials.detect { |trial| trial.id == @trial_sequence[trial_no] }

    unless @trial_definition
      Rails.logger.error "Trial order #{@trial_order.ai} sequence #{@trial_sequence.ai} contains invalid ids #{@trials.ai} for trial index #{trial_no}"
    end

    @trial_definition
  end

  def make_slide(trial_no = 0, protocol_user_id = nil, trial_definition = nil)
    @trial_definition = trial_definition || trial_for_slide_index(trial_no)

    @components = Component.where(trial_query.merge(trial_definition_id: @trial_definition.id)).order(:id).entries
    # @stimuli = Stimulus.where(trial_query).order(:id).entries

    begin
      trial_data = JSON.parse(@trial_definition.definition_data)
      type = (trial_data['type']) if trial_data.key? 'type'
    rescue JSON::ParserError => pe
      Rails.logger.error "Failed to parse trial definition data='#{@trial_definition.definition_data}'"
      Rails.logger.error pe.ai
    end

    if @components.empty?
      # allow no-component slides to be generated by the data definition of the trial
      chaos_trial = [ {
          'Type': type,
          'Id': "#{@study_definition.id}:#{0}",
          'Fullname': 'NewComponent, 1.0.0',
          'UserAnswer': nil,
          'Component': trial_data
      } ]
    else
      chaos_trial = @components.map do |c|
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
          state = data_points.entries.select { |d| d.point_type.eql? 'State' }.first
          outputs = JSON.parse(state.value) if state
        end

        begin
          component_data = JSON.parse(c.definition_data || '{}')
        rescue JSON::ParserError => pe
          Rails.logger.error "Failed to parse component definition data='#{c.definition_data}'"
          Rails.logger.error pe.ai
        end

        type = type || 'NewComponent'

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
