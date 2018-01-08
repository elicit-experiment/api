require 'csv'

class TobiiParser
  attr_accessor :metadata

  def initialize(metadata)
    @metadata = JSON.parse(metadata.gsub("'", '"'))
  end

  def injest
  end

  def query(time_series, query_params)
    csv_opts = { :headers => true, :col_sep => "\t", :return_headers => true}

    trial = nil
    trial_result = nil
    if query_params[:trial_definition_id]
      if query_params[:username]
        trial = TrialDefinition.find_by(id: query_params[:trial_definition_id])
        user = User.find_by(:username => query_params[:username])
        protocol_user = ProtocolUser.find_by(:protocol_definition_id => time_series.protocol_definition_id,
                                             :user_id => user.id)
        trial_result = StudyResult::TrialResult.find_by(:trial_definition_id => query_params[:trial_definition_id],
                                                        :protocol_user_id => protocol_user.id)
      else
        protocol_users = ProtocolUser.includes(:user).where(:protocol_definition_id => time_series.protocol_definition_id)
        protocol_users_map = {}
        protocol_users.each{ |pu| protocol_users_map[pu.user.username] = pu }
      end
    end

    input = CSV.open(time_series.file.file.file, csv_opts)
    Enumerator.new do |yielder|
      header = input.readline()
      yielder << CSV.generate_line(header, csv_opts)
      until input.eof
        row = input.readline()

        if query_params[:username]
          next unless row[self.metadata['user_field']].eql? query_params[:username]
        elsif query_params[:trial_definition_id]
          protocol_user = protocol_users_map[row[self.metadata['user_field']]]
          trial_result = StudyResult::TrialResult.find_by(:trial_definition_id => query_params[:trial_definition_id],
                                                          :protocol_user_id => protocol_user.id)
        end

        date_time_str = row[self.metadata['date_field']] + " " + row[self.metadata['time_field']]
        date_time = DateTime.strptime(date_time_str, "%d-%m-%Y %H:%M:%S.%L")

        if trial_result
          next if (date_time < trial_result.started_at)
          next if (date_time > trial_result.completed_at)
        end

        yielder << CSV.generate_line(row, csv_opts)
      end
    end
  end
end