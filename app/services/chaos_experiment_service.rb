
# A CHAOS experiment is equivalent to a protocol
class ChaosExperimentService

  include Denilize

  attr_accessor :study_definition
  attr_accessor :protocol_definition
  attr_accessor :phase_definition
  attr_accessor :study_result

  def initialize(study_definition, protocol_definition = nil, phase_definition = nil)
    @study_definition = study_definition
    @protocol_definition_definition = protocol_definition
    @phase_definition = phase_definition
    @protocol_definition = ProtocolDefinition.where({
      :study_definition_id => @study_definition.id}).first unless protocol_definition
    @phase_definition = PhaseDefinition.where({
      :study_definition_id => @study_definition.id,
      :protocol_definition_id => @protocol_definition.id}).first unless protocol_definition
  end

  def make_experiment(stage)
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
    #TrialsCompleted: @study_definition.trials_completed,
    FooterLabel: @study_definition.footer_label,
    RedirectOnCloseUrl: @study_definition.redirect_close_on_url,
    CurrentSlideIndex: stage.last_completed_trial,
    Fullname: "Questionnaire, 1.0"
    #Trials: chaos_trials
    }
  end

  def make_slide(trial_no = 0, user_id = nil)
    @phases = PhaseDefinition.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id}).entries
    @phase_order = PhaseOrder.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id}).entries
    
    # TODO: Figure out how to integrate phase orders into the Chaos frontend
    @phase = @phases.first

    @trials = TrialDefinition.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    @trial_order = TrialOrder.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    if @trial_order.empty?
      @trial_order = TrialOrder.default_order(@trials)
    else
      @trial_order = @trial_order.first.sequence_data.split(',').map(&:to_i)
    end

    @components = Component.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries
    @stimuli = Stimulus.where({:study_definition_id => @study_definition.id, :protocol_definition_id => @protocol_definition.id, :phase_definition_id => @phase.id}).entries

    phase = @phases.first

    trial = @trials[@trial_order[trial_no]]

    chaos_trial = @components.select{|c| (c.phase_definition_id == phase.id) and (c.trial_definition_id == trial.id) }.map do |c|
      outputs = {}
      if (user_id != nil)
        data_points = StudyResult::DataPoint.where({:component_id => c.id, :user_id => user_id })
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
    response.Body["FoundCount"] = @trial_order.count
    response.Body["StartIndex"] = trial_no

    response
  end
end