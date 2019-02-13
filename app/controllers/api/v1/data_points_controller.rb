module Api::V1
  class DataPointsController < ApiController

    include StudyCreation

    include StudyResultConcern

    def index
      plural_resource_name = "@#{resource_name.pluralize}"

      pparams = params.permit([:study_id, :protocol_user_id, :phase_definition_id, :trial_definition_id, :component_id])
      filter_fields = pparams
                          .to_h
                          .keys
                          .select{ |p| (p.to_s.end_with?('_id') && !params[p].nil?) }
                          .map{ |p| {p.to_sym => params[p].to_i} }
                          .reduce(&:merge)

      Rails.logger.info "DataPoint where: #{filter_fields.ai}"

      resources = StudyResult::DataPoint.where(filter_fields).includes(:component)

      if not page_params.nil?
        resources = resources
                        .page(page_params[:page])
                        .per(page_params[:page_size])
      end

      cols = StudyResult::DataPoint.column_names.map(&:to_sym)
      ap cols
#      resources = resources.map{ |dp| dp.pluck(*cols).merge({component_name: dp.component.name}) }#map{ |dp| x = dp.to_h; x[:component_name] = x[:component][:name]; delete x[:component]; x}
      #resources = resources.pluck(*cols)
      resources = resources.map do |dp|
        h = dp.as_json
        h[:component_name] = dp.component.name
        h
      end
      ap resources
      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    def default_page_size
      100
    end

    private

    def data_point_params
      params.require([:stage_id]).permit([:protocol_user_id, :phase_definition_id, :trial_definition_id, :component_id])
      permit_json_params(params[:data_point], :data_point) do
        origin = {
            :stage_id => params[:stage_id],
            :protocol_user_id => params[:protocol_user_id],
            :phase_definition_id => params[:phase_definition_id],
            :trial_definition_id => params[:trial_definition_id],
            :component_id => params[:component_id]
        }
        params.require(:data_point).permit([
                                               :kind,
                                               :point_type,
                                               :entity_type,
                                               :value,
                                               :method,
                                               :datetime,
                                           ]).merge(origin)
      end
    end

    def query_params
      {
          :study_result_id => params[:study_result_id],
          :protocol_user_id => params[:protocol_user_id],
          :phase_definition_id => params[:phase_definition_id],
          :component_id => params[:component_id],
          :trial_definition_id => params[:trial_definition_id],
      }
    end
  end
end
