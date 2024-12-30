# frozen_string_literal: true

json.extract! time_series, :id, :created_at, :updated_at, :stage_id, :study_definition_id, :protocol_definition_id, :phase_definition_id, :component_id,
              :series_type, :file_type, :in_progress_file_url, :file_url
