module Api::V1
  class TimeSeriesController < ApiController

    include StudyCreation

    include StudyResultConcern

    def index
      plural_resource_name = "@#{resource_name.pluralize}"

      pparams = params.permit([:study_result_id, :protocol_definition_id, :phase_definition_id, :trial_definition_id])
      where_components = pparams.to_h.keys.select{ |p| (p.to_s.end_with?('_id') && !params[p].nil?) }.map { |p| { p.to_sym => params[p] }  }

      where = where_components.reduce(&:merge)

      resources = StudyResult::TimeSeries.where(where)

      if not page_params.nil?
        resources = resources.page(page_params[:page])
                        .per(page_params[:page_size])
      end
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name), :include => [:user]
    end

    private

    def time_series_params

      params.require([:study_result_id])
      x = permit_json_params(params[:time_series], :time_series) do
        origin = {
            :study_result_id => params[:study_result_id]
        }
        print params.inspect
        print "\n"
        time_series_params = params.require(:time_series)
        print time_series_params.inspect
        print "\n"
#        pep = time_series_params.permit!
        pep = time_series_params.permit([:file, :stage_id])
        ap "pep #{pep.inspect}"
        pep.merge(origin)
      end


      ap x
      x

#      print params.inspect
#      x = params.permit(:study_result_id, :time_series => [:stage_id, :file])
#      ap ""
#      print x.inspect
#      permit_json_params(params[:time_series], :time_series) do
#        origin = {:study_result_id => params[:study_result_id],
#                  :protocol_definition_id => params[:protocol_definition_id],
#                  :phase_definition_id => params[:phase_definition_id],
#                  :trial_definition_id => params[:trial_definition_id]
#        }
#        params.require(:time_series).permit([
#                                               :file,
#                                           ]).merge(origin)
#      end
    end
  end
end
