# frozen_string_literal: true

class PhaseDefinition < ApplicationRecord
  belongs_to :study_definition, class_name: 'StudyDefinition', foreign_key: 'study_definition_id'
  belongs_to :protocol_definition, class_name: 'ProtocolDefinition', foreign_key: 'protocol_definition_id'

  has_many :trial_definitions, dependent: :destroy
  has_many :trial_orders, dependent: :destroy
  has_many :trial_order_selection_mappings, dependent: :destroy

  has_many :stage, class_name: 'StudyResult::Stage', dependent: :destroy

  def trial_order_for_user(user_id)
    trial_order = TrialOrder.where(trial_query_params.merge(user_id: user_id)).first

    Rails.logger.debug "Found suitable user TrialOrder #{trial_order.ai}" if trial_order

    return trial_order if trial_order

    trial_order_id = TrialOrderSelectionMapping
                     .where(user_id: user_id, phase_definition: self)
                     .pluck(:trial_order_id)
                     .first

    trial_order = TrialOrder.find(trial_order_id) if trial_order_id

    Rails.logger.debug "Found suitable non-user TrialOrder via TrialOrderSelectionMapping #{trial_order.ai}" if trial_order

    return trial_order if trial_order

    if trial_ordering == 'RandomWithReplacement'
      trial_order = TrialOrder
                    .where(trial_query_params.merge(user_id: nil))
                    .order('RANDOM()')
                    .first
    elsif trial_ordering == 'RandomWithoutReplacement'
      trial_order = TrialOrder
                    .where(trial_query_params.merge(user_id: nil))
                    .left_joins(:trial_order_selection_mappings)
                    .where(trial_order_selection_mappings: { id: nil })
                    .first
    else
      trial_order = TrialOrder
                    .where(trial_query_params.merge(user_id: nil))
                    .order('RANDOM()')
                    .first
    end

    if trial_order.nil?
      all_trial_orders = TrialOrder.where(trial_query_params)
      Rails.logger.error "Cannot find suitable non-user TrialOrder or user trial for #{user_id} amongst #{all_trial_orders.ai}"
      return nil
    end

    Rails.logger.info "Found suitable non-user TrialOrder or user trial for #{user_id} using trial_ordering #{trial_ordering}: #{trial_order.ai} "

    TrialOrderSelectionMapping.create!(trial_order: trial_order,
                                       user_id: user_id,
                                       phase_definition: self)

    trial_order
  end

  def trial_query_params
    {
      study_definition_id: study_definition_id,
      protocol_definition_id: protocol_definition_id,
      phase_definition_id: id
    }
  end

  include Swagger::Blocks

  swagger_schema :PhaseDefinition do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :trial_ordering do
      key :type, :string
    end
    property :definition_data do
      key :type, :string
    end
  end
end
