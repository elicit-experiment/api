
# A CHAOS experiment is equivalent to a protocol
class ChaosExperimentService

  include Denilize

  attr_accessor :study_definition
  attr_accessor :protocol_definition
  attr_accessor :phase_definition
  attr_accessor :study_result

  def initialize(study_definition, protocol_definition = nil, phase_definition = nil)
    @study_definition = study_definition
    @protocol_definition = protocol_definition
    @phase_definition = phase_definition
    @protocol_definition = ProtocolDefinition.where({
      :study_definition_id => @study_definition.id}).first unless @protocol_definition
    if @protocol_definition.nil?
      Rails.logger.error "No protocols for study #{study_definition.ai}"
      # TODO: we should handle malformed studies by erroring appropriately
    end
    @phase_definition = PhaseDefinition.where({
      :study_definition_id => @study_definition.id,
      :protocol_definition_id => @protocol_definition.id}).first unless @phase_definition
  end

  def make_experiment(experiment)
    stage = experiment.current_stage
    {
    Name: @study_definition.title,
    Css: "",
    Version: @study_definition.version,
    #ExperimentDescription: @study_definition.description,
    CreatedBy: @study_definition.principal_investigator_user_id.to_s,
    #Data: @study_definition.data,
    LockQuestion: @study_definition.lock_question == 1,
    EnablePrevious: @study_definition.enable_previous == 1,
    NoOfTrials: stage.num_trials,
    TrialsCompleted: stage.trials_completed,
    FooterLabel: @study_definition.footer_label,
    RedirectOnCloseUrl: @study_definition.redirect_close_on_url,
    CurrentSlideIndex: (stage.current_trial),
    Fullname: "Questionnaire, 1.0"
    }
  end

  def make_preview_experiment(trial_definition_id)

    trial_params = {:study_definition_id => @study_definition.id,
                    :protocol_definition_id => @protocol_definition.id,
                    :phase_definition_id => @phase_definition.id}
    ap trial_params
    trials = TrialDefinition.where(trial_params)
    trial_ids = trials.map { |t| t.id }
    num_trials = trials.count

    ap trials
    current_trial_idx = trial_ids.index(trial_definition_id)

    trials_completed = current_trial_idx ? (current_trial_idx-1) : nil

    {
        Name: @study_definition.title,
        Css: "",
        Version: @study_definition.version,
        #ExperimentDescription: @study_definition.description,
        CreatedBy: @study_definition.principal_investigator_user_id.to_s,
        #Data: @study_definition.data,
        LockQuestion: @study_definition.lock_question == 1,
        EnablePrevious: @study_definition.enable_previous == 1,
        NoOfTrials: num_trials,
        TrialsCompleted: trials_completed,
        FooterLabel: @study_definition.footer_label,
        RedirectOnCloseUrl: @study_definition.redirect_close_on_url,
        CurrentSlideIndex: current_trial_idx,
        Fullname: "Questionnaire, 1.0"
    }
  end

  def make_slide(trial_no = 0, protocol_user_id = nil)
    @phases = PhaseDefinition.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id}).entries
    @phase_order = PhaseOrder.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id}).entries
    
    # TODO: Figure out how to integrate phase orders into the Chaos frontend
    @phase = @phases.first

    @trials = TrialDefinition.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    @trial_order = TrialOrder.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    if @trial_order.empty?
      @trial_sequence = TrialOrder.default_order(@trials)
    else
      @trial_sequence = @trial_order.first.sequence_data.split(',').map(&:to_i)
    end

    @components = Component.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries
    @stimuli = Stimulus.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    phase = @phases.first

    trial = @trials.detect{ |trial| trial.id == @trial_sequence[trial_no] }

    unless trial
      Rails.logger.error "Trial order #{@trial_order.ai} sequence #{@trial_sequence.ai} contains invalid ids #{@trials.ai}"
    end

    chaos_trial = @components.select{|c| (c.phase_definition_id == phase.id) and (c.trial_definition_id == trial.id) }.map do |c|
      outputs = {}
      if (protocol_user_id != nil)
        data_points = StudyResult::DataPoint.where({:component_id => c.id, :protocol_user_id => protocol_user_id })
        events = data_points.entries.select{ |d| !(d.point_type.eql? "State") }.map do |data_point|
          {
            "Type" => data_point.point_type,
            "EventId" => data_point.kind,
            "Data" => data_point.value,
            "Method" => data_point.method,
            "DateTime" => data_point.datetime
          } if data_point.point_type != "State"
        end
        state = data_points.entries.select{ |d| d.point_type.eql? "State" }.first
        if (state)
          ap state
          outputs = JSON.parse(state.value)
        end
      end
      JSON.parse(c.definition_data).map do |k,v|
        v['Type'] = k
        v['Id'] = "#{@study_definition.id}:#{c.id}"
        v['Fullname'] = "Question, 1.0.0"
        v['UserAnswer'] = nil

        if v["Outputs"]
          output = v["Outputs"]
          output.delete('Validation')
          output = {} unless k.eql? "Monitor"
          output = Denilize.denilize(output)
          v["Output"] = output
        end

        if v["Inputs"]
          input = v["Inputs"]
          v["Input"] = [input]
        end
        
        v["Output"] = outputs
        v.delete("Inputs")
        v
      end
    end.flatten

    #ap chaos_trial
    #ap @components

    response = ChaosResponse.new(chaos_trial)

    # These are necessary to set the counts up for "Slide N/M" in the Chaos frontend
    response.Body["FoundCount"] = @trial_sequence.count
    response.Body["StartIndex"] = trial_no

    response
  end
end