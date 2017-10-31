module Chaos
  class ChaosSession < ApplicationRecord
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    belongs_to :study_definition, :class_name => "StudyDefinition", :foreign_key => "study_definition_id"
    belongs_to :protocol_definition, :class_name => "ProtocolDefinition", :foreign_key => "protocol_definition_id"
    belongs_to :protocol_user, :class_name => "ProtocolUser", :foreign_key => "protocol_user_id"
    belongs_to :phase_definition, :class_name => "PhaseDefinition", :foreign_key => "phase_definition_id"
    belongs_to :experiment, :class_name => "StudyResult::Experiment", :foreign_key => "experiment_id"
    belongs_to :stage, :class_name => "StudyResult::Stage", :foreign_key => "stage_id"

    def populate(current_user_id)
      study_result = StudyResult::StudyResult.where({
        :user_id => current_user_id,
        :study_definition_id => study_definition_id}).first_or_initialize

      study_result.save!
      self.study_result_id = study_result.id

      experiment = StudyResult::Experiment.where({
        :study_result_id => study_result.id,
        :protocol_user_id => protocol_user.id }).first_or_initialize
 
      if !experiment.current_stage
        experiment, stage = next_stage(experiment)
      else
        stage = experiment.current_stage
      end

      stage.save! if stage

      self.experiment_id = experiment.id
      self.stage_id = stage ? stage.id : nil
     end

    def next_stage(experiment = nil)
      experiment = StudyResult::Experiment.where({
        :study_result_id => study_result_id,
        :protocol_user_id => protocol_user.id }).first_or_initialize if experiment.nil?

      ap experiment
      experiment.save!

      completed_stages = StudyResult::Stage.where({
        :experiment_id => experiment.id,
        :protocol_user_id => experiment.protocol_user_id }).where.not({:completed_at => nil})

      phases = PhaseDefinition.where({
        :study_definition_id => study_definition_id,
        :protocol_definition_id => protocol_definition_id})

      # TODO: bring in PhaseOrder

      completed_phase_id_set = Set.new completed_stages.map(&:phase_definition_id)

      next_phases = phases.reject{ |phase| completed_phase_id_set.include? phase.id }

      next_phase = next_phases.first

      Rails.logger.info "Next Phase: #{next_phase.ai}"

      stage = nil

      if !next_phase.nil?
        next_stage = StudyResult::Stage.where({
          :experiment_id => experiment.id,
          :protocol_user_id => experiment.protocol_user_id,
          :phase_definition_id => next_phase.id}).first_or_initialize

        self.stage_id = next_stage.id
        unless next_stage.num_trials
            trial_params = {:study_definition_id => study_definition_id,
                           :protocol_definition_id => protocol_definition_id,
                           :phase_definition_id => next_phase.id}
            trials = TrialDefinition.where(trial_params)
            next_stage.num_trials = trials.count
        end
        next_stage.current_trial = 0 unless next_stage.current_trial
        experiment.current_stage = next_stage
        self.phase_definition_id = next_stage.id

        Rails.logger.info "Next STAGE: #{trials.entries.ai}"
        Rails.logger.info "#{next_stage.ai}"
        next_stage.save!
        stage = next_stage
      else
        self.stage_id = nil
        experiment.current_stage_id = nil
        self.phase_definition_id = nil
      end

      experiment.save!

      return experiment, stage
    end
  end
end
