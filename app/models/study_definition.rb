class StudyDefinition < ApplicationRecord
  belongs_to :principal_investigator, :class_name => "User", :foreign_key => "principal_investigator_user_id"

  has_many :protocol_definitions, :dependent => :delete_all

  include Denilize

  def to_chaos_experiment()
    {
    Name: self.title,
    Css: "",
    Version: self.version,
    #ExperimentDescription: self.description,
    CreatedBy: self.principal_investigator_user_id.to_s,
    #Data: self.data,
    LockQuestion: self.lock_question == 1,
    EnablePrevious: self.enable_previous == 1,
    #NoOfTrials: self.no_of_trials,
    #TrialsCompleted: self.trials_completed,
    FooterLabel: self.footer_label,
    RedirectOnCloseUrl: self.redirect_close_on_url,
    CurrentSlideIndex: 0,
    Fullname: "Questionnaire, 1.0"
    #Trials: chaos_trials
    }
  end

  def to_chaos_questions(trial_no = 0)
    @protocol = ProtocolDefinition.where({:study_definition_id => self.id}).first
    @phases = PhaseDefinition.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id}).entries
    @phase_order = PhaseOrder.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id}).entries
    
    # TODO: Figure out how to integrate phase orders into the Chaos frontend
    @phase = @phases.first

    @trials = TrialDefinition.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id, :phase_definition_id => @phase.id}).entries

    @trial_order = TrialOrder.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id, :phase_definition_id => @phase.id}).entries

    if @trial_order.empty?
      @trial_order = TrialOrder.default_order(@trials)
    else
      @trial_order = @trial_order.first.sequence_data.split(',').map(&:to_i)
    end

    @components = Component.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id, :phase_definition_id => @phase.id}).entries
    @stimuli = Stimulus.where({:study_definition_id => self.id, :protocol_definition_id => @protocol.id, :phase_definition_id => @phase.id}).entries

    phase = @phases.first

    trial = @trials[@trial_order[trial_no]]

    chaos_trial = @components.select{|c| (c.phase_definition_id == phase.id) and (c.trial_definition_id == trial.id) }.map do |c|
        JSON.parse(c.definition_data).map do |k,v|
          v['Type'] = k
          v['Id'] = "#{self.id}:#{c.id}"
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
          
          v.delete("Outputs")
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

  include Swagger::Blocks

  swagger_schema :StudyDefinition do
    key :required, [:principal_investigator_user_id, :title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
    property :description do
      key :type, :string
    end
    property :footer_label do
      key :type, :string
    end
    property :redirect_close_on_url do
      key :type, :string
    end
    property :data do
      key :type, :string
    end
    property :version do
      key :type, :integer
      key :format, :int32
    end
    property :enable_previous do
      key :type, :integer
      key :format, :int32
    end
    property :lock_question do
      key :type, :integer
      key :format, :int32
    end
    property :principal_investigator_user_id do
      key :type, :integer
      key :format, :int64
    end
  end
end
