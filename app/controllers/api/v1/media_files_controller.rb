# frozen_string_literal: true

require 'securerandom'

module Api::V1
  class MediaFilesController < ApiController
    private

    def media_files_params
      permit_json_params(params[:media_file], :media_file) do
        params.require(:media_file).permit(:file)
      end
    end
  end
end
