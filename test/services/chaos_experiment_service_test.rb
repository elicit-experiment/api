# frozen_string_literal: true

require 'test_helper'
require 'minitest/unit'

class ChaosExperimentServiceTest < ActionDispatch::IntegrationTest
  setup do
    @study_def = study_definition(:learning_study)
    @protocol_def = protocol_definition(:learning_study)
    @phase_def = phase_definition(:learning_study)
    @trial_def = trial_definition(:learning_study_1)
    @trial_order = trial_order(:learning_study)
    @trial_order_random = trial_order(:learning_study_random)
    @trial_seq = (1..4).map { |i| "learning_study_#{i}".to_sym }.map { |s| trial_definition(s) }
    @trial_order.sequence_data = @trial_seq.map(&:id).map(&:to_s).join(',')
    @trial_order.save!
    @trial_order_random.sequence_data = @trial_seq.map(&:id).map(&:to_s).join(',')
    @trial_order_random.save!
    @user = user(:subject1)

    @svc = ChaosExperimentService.new(@study_def, @protocol_def, @phase_def, @user.id)
  end

  test 'basic #trial_for_slide_index' do
    @start_trial_def = @svc.trial_for_slide_index
    assert(@start_trial_def.id == @trial_def.id, "wrong trial definition. expected #{@trial_def.ai} got #{@start_trial_def.ai}")
  end

  test 'random #trial_for_slide_index' do
    @phase_def.trial_ordering = 'RandomWithoutReplacement'
    @phase_def.save
    @trial_order.delete
    @start_trial_def = @svc.trial_for_slide_index
    mappings = TrialOrderSelectionMapping.where(trial_order: @trial_order_random,
                                                user: @user,
                                                phase_definition: @phase_def)
    assert(mappings.size == 1, "expected a mapping to have been created #{mappings.ai} #{TrialOrderSelectionMapping.all.entries.ai}")
    assert(@start_trial_def.id == @trial_def.id, "wrong trial definition. expected #{@trial_def.ai} got #{@start_trial_def.ai}")
  end
end
