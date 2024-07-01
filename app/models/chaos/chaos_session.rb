# frozen_string_literal: true

module Chaos
  class ChaosSession < ApplicationRecord
    self.table_name = 'chaos_sessions'

    # attr_accessor :study_definition_id, :protocol_definition_id, :protocol_user_id, :user_id, :study_result_id, :experiment_id, :stage_id, :trial_result_id

    belongs_to :user, class_name: 'User'
    belongs_to :study_definition, class_name: 'StudyDefinition'
    belongs_to :protocol_definition, class_name: 'ProtocolDefinition'
    belongs_to :phase_definition, class_name: 'PhaseDefinition'
    belongs_to :protocol_user, class_name: 'ProtocolUser', optional: true
    belongs_to :phase_definition, class_name: 'PhaseDefinition'
    belongs_to :study_result, class_name: 'StudyResult::StudyResult', optional: true
    belongs_to :experiment, class_name: 'StudyResult::Experiment', optional: true
    belongs_to :stage, class_name: 'StudyResult::Stage', optional: true
    belongs_to :trial_result, class_name: 'StudyResult::TrialResult', optional: true

    def preview?
      protocol_user.nil? || study_result.nil?
    end

    def self.clear_expired!
      ChaosSession.where('expires_at < ?', Date.new).delete_all
    end

    def populate(custom_parameters)
      Rails.logger.info(message: 'populate chaos session')
      study_result = StudyResult::StudyResult.where(
        user_id: user_id,
        study_definition_id: study_definition_id
      ).first_or_initialize

      study_result.save!
      self.study_result_id = study_result.id

      experiment = StudyResult::Experiment.where(
        study_result_id: study_result.id,
        protocol_user_id: protocol_user.id
      ).first_or_initialize.tap do |new_experiment|
        # we need to have a real experiment with an ID for later
        new_experiment.started_at = DateTime.now
        new_experiment.custom_parameters = custom_parameters.as_json
        new_experiment.save!
      end

      if !experiment.current_stage
        experiment, stage = next_stage(experiment)
        stage.started_at = DateTime.now
      else
        stage = experiment.current_stage
        self.phase_definition_id = stage.phase_definition_id
      end

      stage&.save!

      self.experiment_id = experiment.id
      self.stage_id = stage ? stage.id : nil
    end

    def next_stage(experiment = nil)
      experiment ||= StudyResult::Experiment.find_or_initialize_by(
        study_result_id: study_result_id,
        protocol_user_id: protocol_user.id
      )

      completed_stages = StudyResult::Stage.where(
        experiment_id: experiment.id,
        protocol_user_id: experiment.protocol_user_id
      ).where.not(completed_at: nil)

      experiment.num_stages_completed = completed_stages.count

      phases = PhaseDefinition.where(
        study_definition_id: study_definition_id,
        protocol_definition_id: protocol_definition_id
      )

      phase_order = PhaseOrder.where(
        study_definition_id: study_definition_id,
        protocol_definition_id: protocol_definition_id,
        user_id: protocol_user.user_id
      ).first

      phase_sequence = PhaseOrder.default_sequence(phases)

      unless phase_order.nil?
        custom_phase_sequence = phase_order.sequence_data.split(',').map(&:to_i)
        custom_phases = custom_phase_sequence.map { |phase_id| phases.detect { |phase| phase.id == phase_id } }
        if custom_phases.all?
          phase_sequence = custom_phase_sequence
        else
          Rails.logger.error "Phase order #{phase_order.id} sequence #{custom_phase_sequence.ai} contains invalid ids #{custom_phases.ai}"
        end
      end

      completed_phase_id_set = Set.new completed_stages.map(&:phase_definition_id)

      next_phase_ids = phase_sequence.reject { |phase_id| completed_phase_id_set.include? phase_id }

      experiment.num_stages_remaining = next_phase_ids.count

      next_phase_id = next_phase_ids.first

      next_phase = phases.detect { |phase| phase.id == next_phase_id }

      Rails.logger.info message: 'Next Phase', next_phase: next_phase

      stage = nil

      if next_phase.nil?
        Rails.logger.info 'No next phase; ending experiment'
        self.stage_id = nil
        experiment.current_stage_id = nil
        experiment.completed_at = DateTime.now
        self.phase_definition_id = nil

      else
        next_stage = StudyResult::Stage.find_or_initialize_by(
          experiment_id: experiment.id,
          protocol_user_id: experiment.protocol_user_id,
          phase_definition_id: next_phase.id
        )

        self.stage_id = next_stage.id
        unless next_stage.num_trials
          trial_params = { study_definition_id: study_definition_id,
                           protocol_definition_id: protocol_definition_id,
                           phase_definition_id: next_phase.id }
          trials = TrialDefinition.where(trial_params)
          next_stage.num_trials = trials.count
        end
        next_stage.current_trial = 0 unless next_stage.current_trial
        experiment.current_stage = next_stage
        self.phase_definition_id = next_stage.id

        Rails.logger.info(message: 'Next STAGE', trials: trials&.entries)
        Rails.logger.info(message: 'Next stage', next_stage: next_stage)
        next_stage.save!
        stage = next_stage

        self.phase_definition_id = next_phase.id
        save!
      end

      experiment.save!

      [experiment, stage]
    end
  end
end
