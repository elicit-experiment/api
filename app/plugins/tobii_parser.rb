# frozen_string_literal: true

require 'csv'

class TobiiParser
  attr_accessor :metadata

  def initialize(metadata)
    @metadata = JSON.parse(metadata.tr("'", '"'))
  end

  def injest; end

  # TODO: Ideally this would return an iterator
  def query(time_series, query_params)
    csv_opts = { headers: true, col_sep: "\t", return_headers: true }

    user = User.find_by(username: query_params[:user_name]) if query_params[:user_name]
    trial = nil
    trial_results = nil

    all_users = !(query_params[:user_name] || query_params[:group_name])
    all_trials = !(query_params[:trial_definition_id] || query_params[:session_name])

    # if we're filtering on either users or trials, gather the list of users.
    if !all_users || !all_trials
      protocol_user_args = { protocol_definition_id: time_series.protocol_definition_id }
      protocol_user_args[:user_id] = user.id if user
      protocol_user_args[:group_name] = query_params[:group_name] if query_params[:group_name]

      protocol_users = ProtocolUser.includes(:user).where(protocol_user_args)
      Rails.logger.info message: 'protocol_users', protocol_users: protocol_users
      protocol_users_map = protocol_users.index_by { |pu| pu.user.username }
    end

    unless all_trials
      trial_result_params = {
        phase_definition_id: time_series.phase_definition_id
      }
      if query_params[:trial_definition_id]
        trial_result_params = trial_result_params.merge(
          trial_definition_id: query_params[:trial_definition_id]
        )
      end
      if query_params[:session_name]
        trial_result_params = trial_result_params.merge(
          session_name: query_params[:session_name]
        )
      end
      unless all_users
        trial_result_params = trial_result_params.merge(
          protocol_user_id: protocol_users.map(&:id)
        )
      end
      trial_results = StudyResult::TrialResult.where(trial_result_params)
      trial_result_map = protocol_users.map do |pu|
        [pu.user.username,
         trial_results.find_all { |tr| tr.protocol_user_id == pu.id }]
      end.to_h
      Rails.logger.info message: 'Trial_result_map', trial_results: trial_result_map
    end

    input = CSV.open(time_series.file.file.file, csv_opts)
    Enumerator.new do |yielder|
      header = input.readline
      yielder << CSV.generate_line(header, csv_opts)
      until input.eof
        row = input.readline
        row_user = row[metadata['user_field']]

        unless all_users
          next if query_params[:user_name] && !(row_user.eql? query_params[:user_name])

          next if protocol_users_map && !protocol_users_map.key?(row_user)
        end

        unless all_trials
          date_time_str = "#{row[metadata['date_field']]} #{row[metadata['time_field']]}"
          date_time = DateTime.strptime(date_time_str, '%d-%m-%Y %H:%M:%S.%L')

          matching_trial = false
          trial_results = trial_result_map[row_user]

          trial_results.each do |trial_result|
            next unless (date_time >= trial_result.started_at) &&
                        (date_time <= trial_result.completed_at)

            matching_trial = true
            break
          end

          next unless matching_trial
        end

        yielder << CSV.generate_line(row, csv_opts)
      end
    end
  end
end
