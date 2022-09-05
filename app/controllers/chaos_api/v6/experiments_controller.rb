# frozen_string_literal: true

module ChaosApi
  module V6
    class ExperimentsController < ApplicationController
      include ActionController::MimeResponds

      def index
        # show all experiments
        @experiments = StudyDefinition.all.map(&:to_chaos)
        Rails.logger.info message: 'experiments', experiments: @experiments.ai

        respond_to do |format|
          format.json { render json: @experiments }
          format.xml  { render xml: @experiments }
        end
      end

      def show
        id = params[:id]
        session_guid = params[:sessionGUID]

        @chaos_session = Chaos::ChaosSession.where(session_guid: session_guid).includes([:stage,
                                                                                         :study_definition,
                                                                                         :protocol_definition,
                                                                                         :phase_definition,
                                                                                         { experiment: :current_stage }]).first

        service = ChaosExperimentService.new(@chaos_session.study_definition,
                                             @chaos_session.protocol_definition,
                                             @chaos_session.phase_definition)

        if @chaos_session.preview
          @experiment = service.make_preview_experiment(@chaos_session.trial_definition_id)

          @results =  [@experiment]
          @response = ChaosResponse.new(@results)
        elsif @chaos_session.experiment.current_stage
          Rails.logger.info message: 'Current experiment', experiments: @chaos_session.experiment
          @experiment = service.make_experiment(@chaos_session.experiment)

          @results =  [@experiment]
          @response = ChaosResponse.new(@results)
        else
          @response = ChaosResponse.new(@results, 'Experiment is already complete')
        end

        respond_to do |format|
          format.html { redirect_to "#{root_url.chomp('/')}:8080/#Experiment/#{id}" }
          format.xml  { render xml: @response.to_xml }
          format.json { render json: @response.to_json }
        end
      end

      private def post_params
        # validate POST parameters
        params.require(:experiment).permit(:author_id, :name)
      end
    end
  end
end
